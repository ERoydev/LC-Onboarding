
#[derive(Clone, Copy)]
pub struct FutureStatus {
    pub succeeded: bool, 
    pub failed: bool,
    pub execution_time: u32,
}

impl FutureStatus {
    const DEFAULT_EXECUTION_TIME: u32 = 0;
}

impl Default for FutureStatus {
    fn default() -> Self {
        Self {
            succeeded: false,
            failed: false,
            execution_time: FutureStatus::DEFAULT_EXECUTION_TIME,
        }
    }
}