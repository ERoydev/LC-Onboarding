use std::sync::{Arc, Mutex};

use crate::priority::priority::Priority;
use crate::rate_limiting::slot_rate_limiter::SlotRateLimiter;
use crate::core::executor::AsyncExecutor;

#[derive(Debug, Clone)]
pub struct Proxy {
    executor: Arc<Mutex<AsyncExecutor>>,
}

impl Proxy {
    pub fn new() -> Proxy {
        Proxy {
            executor: AsyncExecutor::new(), // Starts Threads(Workers) and Channel
        }
    }

    // This is what stands between the user and my executor
    pub fn task<F>(&mut self, fut: F, priority: Priority)   
    where 
        F: Future<Output = ()> + Send + 'static
    {   
        // TODO: I can implement more general logic to apply all limits from base_rate_limiter and after all (layers) pass then i delay() the task to executor
        // Have that in mind when creating addional rate limiting strategies
        let mut slot_rate_limiter = SlotRateLimiter::new(self.executor.lock().unwrap().config.rate_limit_per_sec);
        slot_rate_limiter.slot_limited(priority, self.executor.lock().unwrap().clone(), Box::pin(fut));
    }   

    pub fn await_completion(&self) {
        self.executor.lock().unwrap().wait_all();
    }

    pub fn metrics(&mut self) {
        self.executor.lock().unwrap().metrics.lock().unwrap().metrics_info();
    }


    pub fn force_shutdown(&mut self) {
        self.executor.lock().unwrap().force_shutdown();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicUsize, Ordering};
    use std::time::Duration;
    use std::thread;


    #[test]
    fn test_metrics() {
        let mut proxy = Proxy::new();
        proxy.metrics(); 
    }

    #[test]
    fn test_task_execution() {
        let mut proxy = Proxy::new();
        let counter = Arc::new(AtomicUsize::new(0));
        let counter_clone = counter.clone();

        proxy.task(
            async move {
                counter_clone.fetch_add(1, Ordering::SeqCst);
            },
            Priority::Medium,
        );

        thread::sleep(Duration::from_millis(100));
        proxy.await_completion();

        assert_eq!(counter.load(Ordering::SeqCst), 1);
    }
}
