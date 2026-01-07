use std::{task::Poll, thread, time::{Duration, Instant}};

use crate::error_handler::error_handler::{fail_gracefully, ExecutorError};
use std::task::Context;
use futures::task::noop_waker;

use super::{future_status::FutureStatus, future_types::FutureTypes};

pub struct CustomFutureExecutorTimeout {
    status: FutureStatus,
    future: FutureTypes,
}

impl CustomFutureExecutorTimeout {
    pub fn poll_future(&mut self, timeout: Duration) -> FutureStatus {
        let start = Instant::now(); // Timer stars here
        let timeout = timeout;

        let waker = noop_waker();
        let mut cx = Context::from_waker(&waker);

        let future = match self.future.clone() {
            FutureTypes::FutureNoOutput(fut) => fut,
        };

        loop {
            // Here i can check if task is running on a thread and which task is running on this thread

            // When Poll::Pending i will check if this is true => TIMEOUT CHECKER === 
            if start.elapsed().as_secs() >= timeout.as_secs() {
                self.status.failed = true;
                
                fail_gracefully(ExecutorError::Timeout, "Task timed out!");
                drop(future); // Cancel the task via timeout
                break;
            }

            match future.lock().unwrap().as_mut().poll(&mut cx) {
                Poll::Ready(()) => {
                    let duration = start.elapsed();
                    println!("\n✅ Task finished in {:?}.\n", duration);
                    self.status.execution_time = duration.as_secs() as u32;
                    self.status.succeeded = true;

                    return self.status;
                }
                Poll::Pending => {
                    // Waiting the task to get completed
                    thread::sleep(Duration::from_millis(10)); // polling interval => Meaning it with continue looping until Poll:Ready() or drop(future)
                }
            };
        };  
        self.status.failed = true;
        self.status
    }

    pub fn new(fut: FutureTypes) -> CustomFutureExecutorTimeout {
        CustomFutureExecutorTimeout { 
            status: FutureStatus::default(), 
            future: fut,
        }
    }
}


// ORIGINAL USED LOOP
/*
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

*/