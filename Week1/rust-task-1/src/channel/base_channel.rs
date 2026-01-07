use std::time::Duration;
use futures_timer::Delay;

use super::types::*;

// Other channels will inherit this struct
pub trait BaseChannel {
    fn initialize_channel() -> Channel;
}



// Type of channels i can currently create
pub enum Channel {
    WorkerChannel (SenderType, ReceiverType),
    ShutdownChannel (ShutdownSender, ShutdownReceiver)
}

impl Channel {
    // To validate if channel is working before returning to executor
    pub async fn validation_future_function() {
        println!("Sending an email....");
        Delay::new(Duration::from_secs(3)).await;
        println!("Email sended successfully!")
    }
}