use std::sync::Arc;
use crossbeam::channel::Sender;
use crate::{channel::types::ShutdownSender, executor_config::ExecutorConfig};
use super::types::Task;



pub type ConfigParamsArc = Arc<ExecutorConfig>;

pub type WorkerSenderOpt = Option<Sender<Task>>;   

pub type ShutdownSenderArc = Arc<ShutdownSender>;