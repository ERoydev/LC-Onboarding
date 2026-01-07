use crossbeam::channel::{Receiver, Sender};
use std::pin::Pin;

// Used for workers channel
pub type SenderType = Sender<Pin<Box<dyn Future<Output = ()> + Send>>>;
pub type ReceiverType = Receiver<Pin<Box<dyn Future<Output = ()> + Send>>>;

// Used for shutdown channel
pub type ShutdownSender = Option<Sender<()>>;
pub type ShutdownReceiver = Option<Receiver<()>>;
