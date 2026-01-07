use log::info;
use thiserror::Error;


#[derive(Debug, Error)]
pub enum ExecutorError {
    // task timeouts => if task.time > 5sec = Task fail
    #[error("Too much tasks, not enough workers!")]
    Overload,

    #[error("Executor failed to handle this task execution!")]
    Fail,

    #[error("Something went wrong, please try again later!")]
    Other,

    #[error("Task execution took longer that 5 seconds!")]
    Timeout,

    #[error("Rate Limit exceeded!")]
    RateLimitExceeded,

    #[error("Worker Pool is Full!")]
    WorkerPoolFull,

    #[error("Channel is not working")]
    ChannelConnectionIsNotEstablished,

    #[error("Shutdown error")]
    ShutDownError
}

// This is panic Wrapper
pub fn fail(error: ExecutorError, context: String) -> ! {
    panic!("Execution failed with Error: {}, Custom Message: {}", error, context);
}

pub fn fail_gracefully(error: ExecutorError, context: &str) {
    // It's print for debuging purposes
    eprintln!("[ERROR] {:?} - Context: {}", error, context);
    
    // This is production log
    info!("[ERROR] {:?} - Context: {}", error, context)
}