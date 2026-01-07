use std::{sync::{atomic::{AtomicBool, Ordering}, Arc, Mutex}, time::Instant};

use crate::{executor_config::ExecutorConfig, performance_monitoring::metrics::MetricsReport, worker::{base_worker::BaseWorker, future_executor_worker::FutureExecutorBuilder}};
use crate::error_handler::error_handler::{fail, ExecutorError};

use crate::channel::{worker_channel::WorkerChannelBuilder, shutdown_channel::ShutdownChannelBuilder};
use crate::channel::types::{ShutdownReceiver, ReceiverType};

use super::{executor_types::{ConfigParamsArc, ShutdownSenderArc, WorkerSenderOpt}, types::{MetricsData, ProxyExecutor, StopFlag, Task, WorkerHandles}};
/*
NOTE:
With my approach:
    - Threads are running in Parallel
    - Access to the shared data (via Mutex) is sequentially, not parallel.
*/

#[derive(Debug, Clone)]
pub struct AsyncExecutor {
    // Accepts tasks (async fn, futures)
    // 5 jobs/sec rate limit
    // Concurrencty
    // Handles shutdowns, all tasks are (completed, canceled)
    stop_flag: StopFlag, // Use to force stop all threads
    pub config: ConfigParamsArc,
    pub metrics: MetricsData, // Store metric values -> Using Arc and Mutex because my threads will update this value in parallel and this can cause error
    worker_handles: WorkerHandles, // I use this to track running tasks and ensure they are waited instead of application shut down when main() finish => a common problem with std::threads
    sender: WorkerSenderOpt, // Since i want to use one channel and i need to safe my sender address to be able to send from many scopes 
    shutdown_ack_tx: ShutdownSenderArc, // clone into each worker
    shutdown_ack_rx: ShutdownReceiver, // Receiver for N shutdown signals
}

impl AsyncExecutor {
    pub fn new() -> ProxyExecutor {
        let config =   Arc::new(ExecutorConfig::default());

        let mut executor_instance = AsyncExecutor { 
            stop_flag: Arc::new(AtomicBool::new(false)),
            config,
            metrics: Arc::new(Mutex::new(MetricsReport::new())),
            worker_handles: Arc::new(Mutex::new(vec![])),
            sender: None, // No channel when initialized
            shutdown_ack_rx: None,
            shutdown_ack_tx: Arc::new(None),

            // With Arc i pass the Rust ownership rules and allow this to be shared accross my threads without dropping too early
            // While Mutex ensures that only one thread access and mutate data at a time
        };

        // Create the shutdown channel
        let (shd_tx, shd_rx) = ShutdownChannelBuilder::create_channel();
        executor_instance.shutdown_ack_tx = Arc::new(shd_tx);
        executor_instance.shutdown_ack_rx = shd_rx;


        // Here i set the channel for my workers threads. So i provide only the workers with the receiver of this channel
        let (w_tx, w_rx) = WorkerChannelBuilder::create_channel(); // Create the channel for communication -> .delay() sends to workers tasks
        executor_instance.sender = Some(w_tx); // Set the sender
        executor_instance.spawn_workers(w_rx); // Pass to workers so the can receive via this channel tasks sended from delay() 
 
        Arc::new(Mutex::new(executor_instance))
    }

    pub fn force_shutdown(&mut self) {
        println!("SHUTDOWN STARTED");
        let timeout = self.config.get_shutdown_timeout(); // TODO: Implement the timeout functionality for shutdown
        let deadline = Instant::now() + timeout;

        let mut shutdowns = 0;
        let total_threads = self.config.get_total_workers();
        
        while shutdowns < total_threads {
            let now = Instant::now();

            if now >= deadline {
                // SHUTDOWN TIMED OUT
                fail(ExecutorError::ShutDownError, "Shutdown timed out, please check the passed functions".to_string())
            }

            let remaining = deadline - now;
            match self.shutdown_ack_rx.as_ref().unwrap().recv_timeout(remaining) {
                Ok(_) => {
                    shutdowns += 1;
                }
                Err(_) => {
                    fail(ExecutorError::ShutDownError, "Shutdown timed out, please check the passed functions".to_string())
                }
            }
        }
        println!("ALL Threads are closed sucessfully. Number of closed threads: {}", shutdowns);
        self.stop_flag.store(true, Ordering::Relaxed);
        drop(self.sender.clone()); // Drop the sender -> Destory the channel 

    }

    pub fn delay(&self, fut: Task) {
        let task: Task = fut;

        let sender = match &self.sender {
            Some(v) => v,
            None => fail(ExecutorError::Other, String::from("Failed when sending task to channel!"))
        };

        sender.send(task).err(); // Send this task through the channel and workers receive it
    }

    pub fn wait_all(&mut self) {
        // Wait till all functions are over because main will finish and will terminate every async unfinished task it will not wait thats why i create this fn
        
        self.sender = None;// Drop the sender to close the channel

        let mut handles = self.worker_handles.lock().unwrap_or_else(|_| fail(ExecutorError::Fail, String::from("Failed when tried to lock value using Mutex in .wait_all()")));

        // drain() removes all elements from the vector and returns an iterator over them `..` means full range
        for handle in handles.drain(..) {
            handle.join().unwrap_or_else(|_| fail(ExecutorError::Fail, String::from("Failed when waiting for task execution")));
        }
    }

    fn spawn_workers(&mut self, rx: ReceiverType) {
        // This is the workers thread created when this struct is initialized
        let allowed_workers = self.config.get_total_workers();
        println!("\n===> Using 3/4 of total CPU cores as workers count. Workers allowed: {}\n", allowed_workers);

        // I have fixed workers and it works without validation, because when i have free worker he takes a task trough the channel, when all workers are busy => tasks are waiting in the channel!

        /*
            In tipical Rust i will have Ownership problem when i want to mutate some field from the struct, because in my thread i use `move` keyword => Ownership and Lifetimes issues
             - Thats why i use Arc to create Shared State -> A reference to the original data stored in the heap
             - And mutex to lock this data while i make some changes inside
         */
        
        // Spawn multiple threads(workers) that each listens to the channel to recieve a task
        for _ in 0..allowed_workers {
            let rx_clone = rx.clone();
            let metrics_clone = self.metrics.clone(); // with clone() that comes from Arc i create a reference to he heap stored metrics
            let stop_flag = self.stop_flag.clone();
            let shutdown_arc_sender_clone = self.shutdown_ack_tx.clone();

            // Instantiate the worker required
            let future_executor = FutureExecutorBuilder::new(rx_clone, metrics_clone, stop_flag, shutdown_arc_sender_clone);

            // THREAD SPAWN HERE -------->
            let handle = future_executor.spawn_thread(self.config.task_timeout); // Spawn the thread from my worker

            // Collect all handles
            self.worker_handles
                .lock()
                .unwrap_or_else(|_| fail(ExecutorError::Fail, String::from("Failed when tried to add spawn handle to worker_handles!")))
                .push(handle);

            // lock() is the Mutex way to ensure that only this thread is mutating this data at this time
            // Note: This is blocking the other threads that run in parallel until this release MutexGuarded data
        }
    }
}

#[cfg(test)]
mod tests {
    use std::{pin::Pin, thread::{self, available_parallelism, JoinHandle}};

    use crossbeam::channel::{self, Sender};
    use futures::executor::block_on;

    use super::*;
    use crate::{executor_config::ExecutorConfig, testing_functions::*};

    fn setup_channel() -> (Sender<Pin<Box<dyn Future<Output = ()> + Send>>>, ReceiverType) {
        let (tx, rx) = channel::unbounded::<Task>();
        (tx, rx)
    }

    fn setup_total_workers() -> usize {
        let default_parallelism_approx: usize = available_parallelism().unwrap().get();

        let workers_count: usize = default_parallelism_approx - default_parallelism_approx / 4;
        workers_count
    }

    fn setup_executor() -> AsyncExecutor {
        let config = Arc::new(ExecutorConfig::default());
        let metrics = Arc::new(Mutex::new(MetricsReport::new()));
        let worker_handles = Arc::new(Mutex::new(vec![]));
        let stop_flag = Arc::new(AtomicBool::new(false));

        AsyncExecutor { 
            stop_flag,
            config,
            metrics, 
            worker_handles, 
            sender: None,
            shutdown_ack_tx: Arc::new(None),
            shutdown_ack_rx: None,
        }
    }

    #[test]
    fn test_new_executor_init_should_be_valid_returns_executor_instance() {
        let metrics = Arc::new(Mutex::new(MetricsReport::new()));
        let worker_handles: Arc<Mutex<Vec<JoinHandle<()>>>> = Arc::new(Mutex::new(vec![]));

        let executor = AsyncExecutor::new();

        assert_eq!(*executor.lock().unwrap().metrics.lock().unwrap(), *metrics.lock().unwrap());
        assert!(worker_handles.lock().unwrap().is_empty());
        assert!(executor.lock().unwrap().sender.is_some());
    }

    #[test]
    fn test_delay_with_correct_function_should_be_valid() {
        let (sender, receiver) = setup_channel();
        let mut executor = setup_executor();
        executor.sender = Some(sender);

        executor.delay(Box::pin(send_email()));

        let rx_clone = receiver.clone();
        
        let handle = thread::spawn(move || {
            while let Ok(task) = rx_clone.recv() {
                block_on(task); // Single threaded execution
            }
        });

        executor.worker_handles
            .lock()
            .unwrap()
            .push(handle);

        executor.wait_all();
        assert!(true);
    }

    #[test]
    #[should_panic]
    fn test_delay_when_sender_is_none_should_panic() {
        let executor = setup_executor();
        executor.delay(Box::pin(send_email()));
    }

    #[test]
    fn test_wait_all_passing_two_tasks_should_be_valid() {
        let (tx, rx) = setup_channel();
        let mut executor = setup_executor();
        executor.sender = Some(tx);

        let start = Instant::now();

        let rx_clone = rx.clone();

        executor.delay(Box::pin(send_email()));
        executor.delay(Box::pin(send_birthday_present()));
        

        let handle = thread::spawn(move || {
            while let Ok(task) = rx_clone.recv() {
                block_on(task); // Single threaded execution
            }
        });

        executor.worker_handles
            .lock()
            .unwrap()
            .push(handle);

        executor.wait_all();

        assert_eq!(start.elapsed().as_secs(), 2); // Should take 2 seconds
        assert!(true);
    }

    #[test]
    fn test_get_machine_cores_should_be_valid() {
        let total_workers = setup_total_workers();

        let executor = AsyncExecutor::new();

        let workers_result = executor.lock().unwrap().config.get_total_workers();
        assert_eq!(total_workers, workers_result);
    }
}