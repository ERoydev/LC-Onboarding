use super::base_worker::BaseWorker;
use std::sync::Arc;
use std::thread::{self, JoinHandle};
use std::{sync::atomic::Ordering, time::Duration};

use crate::channel::types::{ReceiverType, ShutdownSender};
use crate::core::types::{MetricsData, StopFlag};
use crate::future_executors::future_executor_with_timeout::CustomFutureExecutorTimeout;
use crate::future_executors::future_types::receive_future_no_output;

pub struct FutureExecutorBuilder {
    rx_clone: ReceiverType,
    metrics_clone: MetricsData,
    stop_flag: StopFlag,
    shutdown_arc_sender: Arc<ShutdownSender>,
}

impl FutureExecutorBuilder {
    pub fn new(rx_clone: ReceiverType, metrics_clone: MetricsData, stop_flag: StopFlag, shutdown_arc_sender: Arc<ShutdownSender>) -> FutureExecutorBuilder {
        FutureExecutorBuilder {
            rx_clone,
            metrics_clone,
            stop_flag,
            shutdown_arc_sender
        }
    }
}

impl BaseWorker for FutureExecutorBuilder {
    fn spawn_thread(self, timeout: Duration) -> JoinHandle<()> {
        let handle = thread::spawn(move || {
            // Here i can check if worker Thread is started using Prints
            // let rx = rx_clone.lock().unwrap(); // When i leave this here locks entire receiver for the lifetime of this worker thread others are blocked and this makes my workers work sequentially
            
            while !self.stop_flag.load(Ordering::Relaxed) {
                match self.rx_clone.recv_timeout(Duration::from_millis(100)) {
                    Ok(task) => {
                        println!("\n🛠️  Task is running on thread: {:?}\n",std::thread::current().id());
                        self.metrics_clone.lock().unwrap().increment_task_count();

                        let mut future_exec = CustomFutureExecutorTimeout::new(receive_future_no_output(task));
                        let status = future_exec.poll_future(timeout); 

                        if status.failed {
                            self.metrics_clone.lock().unwrap().increment_tasks_failed();
                        } else {
                            self.metrics_clone.lock().unwrap().increment_total_execution_time(status.execution_time);
                        }
                    }
                    Err(crossbeam::channel::RecvTimeoutError::Timeout) => {
                        // Timeout hit, check stop flag
                        continue;
                    }

                    Err(crossbeam::channel::RecvTimeoutError::Disconnected) => {
                        // println!("💀 Channel disconnected");
                        break;
                    }
                }

            }
            let _ = self.shutdown_arc_sender.as_ref().as_ref().unwrap().send(()); // SENDS A SIGNAL WHEN THE THREAD IS CLOSED
        });
        handle
    }
}

// OLDER WORKING IMPLEMENTATION OF THIS
/*
fn spawn_thread(self) -> JoinHandle<()> {
        let handle = thread::spawn(move || {
            // Here i can check if worker Thread is started using Prints
            // let rx = rx_clone.lock().unwrap(); // When i leave this here locks entire receiver for the lifetime of this worker thread others are blocked and this makes my workers work sequentially
            
            while !self.stop_flag.load(Ordering::Relaxed) {
                match self.rx_clone.recv_timeout(Duration::from_millis(100)) {
                    Ok(task) => {
                        let start = Instant::now(); // Timer stars here
                        let timeout = Duration::from_secs(5);

                        // Pin Future
                        let mut future = task;

                        let waker = noop_waker();
                        let mut cx = Context::from_waker(&waker);

                        self.metrics_clone.lock().unwrap().increment_task_count();

                        println!("\n🛠️  Task is running on thread: {:?}\n",std::thread::current().id());

                        /*
                        Custom Future Executor:
                            - Here is my custom Executor using Future poll instead of using async await syntax => In the older rust versions rust programmers did it this way.
                            - I decided to do it this way because it gives me control when to cancel Future execution while with block_on() method
                                or other thread methords i cannot stop task that easily and it could continue running in background even if i count it as failed.
                        */
                        loop {
                            // Here i can check if task is running on a thread and which task is running on this thread

                            // When Poll::Pending i will check if this is true => TIMEOUT CHECKER === 
                            if start.elapsed().as_secs() >= timeout.as_secs() {
                                self.metrics_clone.lock().unwrap().increment_tasks_failed();

                                fail_gracefully(ExecutorError::Timeout, "Task timed out!");
                                drop(future); // Cancel the task via timeout
                                break;
                            }

                            match future.as_mut().poll(&mut cx) {
                                Poll::Ready(()) => {
                                    let duration = start.elapsed();
                                    println!("\n✅ Task finished in {:?}.\n", duration);
                                    self.metrics_clone.lock().unwrap().increment_total_execution_time(duration.as_secs() as u32);
                                    break;
                                }
                                Poll::Pending => {
                                    // Waiting the task to get completed
                                    thread::sleep(Duration::from_millis(10)); // polling interval => Meaning it with continue looping until Poll:Ready() or drop(future)
                                }
                            };
                        };   
                    }
                    Err(crossbeam::channel::RecvTimeoutError::Timeout) => {
                        // Timeout hit, check stop flag
                        continue;
                    }

                    Err(crossbeam::channel::RecvTimeoutError::Disconnected) => {
                        // println!("💀 Channel disconnected");
                        break;
                    }
                }

            }
            let _ = self.shutdown_arc_sender.as_ref().as_ref().unwrap().send(()); // SENDS A SIGNAL WHEN THE THREAD IS CLOSED
        });
        handle
    }
*/