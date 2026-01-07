
use std::{thread::JoinHandle, time::Duration};

pub trait BaseWorker {
    fn spawn_thread(self, timeout: Duration) -> JoinHandle<()>;
}


pub enum Worker {
    FutureExecutor
}