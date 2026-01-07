

use std::sync::{Arc, Mutex};

use crate::core::types::Task;

use super::types::MutableFuture;


#[derive(Clone)]
pub enum FutureTypes {
    FutureNoOutput(MutableFuture),
}

pub fn receive_future_no_output(fut: Task) -> FutureTypes {
    let mutable_future = Arc::new(Mutex::new(fut));
    FutureTypes::FutureNoOutput(mutable_future)
}
