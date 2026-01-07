use std::{pin::Pin, sync::{atomic::AtomicBool, Arc, Mutex}, thread::JoinHandle};

use crate::{executor_config::ExecutorConfig, performance_monitoring::metrics::MetricsReport};

use super::executor::AsyncExecutor;


// Since this is `dyn trait` -> Rust doesn't know how much stack space to reserve -> Thats why i Pin and Box(Smart pointers) into heap memory where dynamic values are stored
pub type Task = Pin<Box<dyn Future<Output = ()> + Send + 'static>>;

pub type WorkerHandles = Arc<Mutex<Vec<JoinHandle<()>>>>;

pub type MetricsData = Arc<Mutex<MetricsReport>>;
pub type StopFlag = Arc<AtomicBool>;

pub type ProxyExecutor = Arc<Mutex<AsyncExecutor>>;
pub type ProxyExecutorConfig = Arc<ExecutorConfig>;