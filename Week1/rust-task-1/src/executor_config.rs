use std::{thread::available_parallelism, time::Duration};


#[derive(Debug, Clone)]
pub struct ExecutorConfig {
    pub rate_limit_per_sec: usize,
    pub task_timeout: Duration,
    pub worker_count: usize, 
    pub shutdown_timeout: Duration,
}

impl ExecutorConfig {
    const DEFAULT_RATE_LIMIT: usize = 5; // Default constant for this class
    const DEFAULT_TASK_TIMEOUT: Duration = Duration::from_secs(5);
    const DEFAULT_SHUTDOWN_TIMEOUT: Duration = Duration::from_secs(10);


    fn get_machine_cores() -> usize {
        let default_parallelism_approx: usize = available_parallelism().unwrap().get(); // Returns the capacity for parallelism
        // Corresponds to the amount of CPU's the running computer has i will use 3/4 of the total cores of the CPU
        // Example MacBook 16 has 10 cores and i am going to use only 8 of them

        let workers_count: usize = default_parallelism_approx - default_parallelism_approx / 4;
        workers_count
    }

    pub fn get_total_workers(&self) -> usize {
        self.worker_count
    }

    pub fn get_task_timeout(&self) -> Duration {
        self.task_timeout
    }

    pub fn get_shutdown_timeout(&self) -> Duration {
        self.shutdown_timeout
    }
}

impl Default for ExecutorConfig {
    fn default() -> Self {
        let workers_allowed = ExecutorConfig::get_machine_cores();

        Self {
            rate_limit_per_sec: ExecutorConfig::DEFAULT_RATE_LIMIT,
            task_timeout: ExecutorConfig::DEFAULT_TASK_TIMEOUT,
            worker_count: workers_allowed,
            shutdown_timeout: ExecutorConfig::DEFAULT_SHUTDOWN_TIMEOUT,
        }
    }
}