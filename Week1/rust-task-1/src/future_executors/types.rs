use std::sync::{Arc, Mutex};


use crate::core::types::Task;



pub type MutableFuture = Arc<Mutex<Task>>;