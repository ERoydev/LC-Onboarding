use crate::{core::executor::AsyncExecutor, core::types::Task};


pub trait BaseRateLimiter {
    fn delay_task_after_limit_pass(&self, executor: AsyncExecutor, fut: Task); // Sends the task after limits are passed for this task
}
