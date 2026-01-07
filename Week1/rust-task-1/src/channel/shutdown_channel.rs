use super::base_channel::{BaseChannel, Channel};

use crossbeam::channel;
use super::types::{ShutdownSender, ShutdownReceiver};
use crate::error_handler::error_handler::{fail, ExecutorError};

pub struct ShutdownChannelBuilder;

impl ShutdownChannelBuilder {
    pub fn create_channel() -> (ShutdownSender, ShutdownReceiver) {
        let channel = ShutdownChannelBuilder::initialize_channel();

        let (tx, rx) = ShutdownChannelBuilder::validate_channel(channel);

        (tx, rx)
    }

    pub fn validate_channel(channel: Channel) -> (ShutdownSender, ShutdownReceiver) {
        match channel {
            Channel::ShutdownChannel(tx, rx) => {
                let sender = tx.unwrap();
                let receiver = rx.unwrap();

                sender.send(()).unwrap();

                let _ = receiver.recv().unwrap();      

                return (Some(sender), Some(receiver))     
            }
            _ => {
                fail(ExecutorError::ChannelConnectionIsNotEstablished, "The connection to channel is not established!".to_string());
            }
        }
    }
}

impl BaseChannel for ShutdownChannelBuilder {
    fn initialize_channel() -> Channel {
        let (tx, rx) = channel::unbounded();

        Channel::ShutdownChannel(Some(tx),  Some(rx))
    }
}
