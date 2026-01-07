use super::base_channel::{BaseChannel, Channel};
use crossbeam::channel;
use super::types::{SenderType, ReceiverType};
use crate::error_handler::error_handler::{fail, ExecutorError};
use crate::core::types::Task;

pub struct WorkerChannelBuilder;

impl WorkerChannelBuilder {
    pub fn create_channel() -> (SenderType, ReceiverType) {
        let channel = WorkerChannelBuilder::initialize_channel();

        let (tx, rx) = WorkerChannelBuilder::validate_channel(channel);

        (tx, rx)
    }

    pub fn validate_channel(channel: Channel) -> (SenderType, ReceiverType) {
        let task = Box::pin(Channel::validation_future_function());

        match channel {
            Channel::WorkerChannel(tx, rx) => {
                tx.send(task).unwrap();

                let _ = rx.recv().unwrap();      

                return (tx, rx)     
            }
            _ => {
                fail(ExecutorError::ChannelConnectionIsNotEstablished, "The connection to channel is not established!".to_string());
            }
        }
    }
}

impl BaseChannel for WorkerChannelBuilder {
    fn initialize_channel() -> Channel {
        let (tx, rx) = channel::unbounded::<Task>();
        Channel::WorkerChannel(tx, rx)
    }
}
