

trait VerySimpleFuture {
    type Output;
    /// Do work and check if task is completed.
    /// Returns [Poll::Ready], containing the
    /// `Output` if task is ready,
    /// [Poll::Pending] if not
    fn poll(&mut self) -> Poll<Self::Output>; // Simply Poll means -> Are you done or not ?
}

// Represents two possible situations when poll asks `if done or not`
enum Poll<T> {
    Ready(T),
    Pending,
}

struct VerySimpleAlarm {
    alarm_time: Instant,
}

impl VerySimpleFuture for VerySimpleAlarm {
    type Output = ();

    fn poll(&mut self) -> Poll {
        if Instant::now() >= self.alarm_time {
            Poll::Ready(())
        } else {
            Poll::Pending
        }
    }
}

fn main() {
    let mut first_alarm = VerySimpleAlarm {
        alarm_time: Instant::now() + Duration::from_secs(3)
    };

    let mut snooze_alarm = VerySimpleAlarm {
        alarm_time: Instant::now() + Duration::from_secs(5)
    };

    // This is bad approach of looping its terrible
    loop {
        if let Poll::Ready(_) = first_alarm.poll() {
            println!("Beep beep beep");
        }

        if let Poll::Ready(_) = snooze_alarm.poll() {
            println!("You are late for work!")
        }
    }
    /*
        We want to be able to be told when we ready, when we might be ready
        Future -> which is waiting for some internet request to complete something
        We ask our OS to wake us up when some stuff is happening on the network

        The Question is:
            - How to signal the executo the future is actually ready to be polled?

        INTRODUCE A WAKER
            - Run some callback to notify executor
            - Have executor implement some job queue
     */
}

// NEW FITURE IMPLEMENTATION 

trait SimpleFuture {
    type Output;

    fn poll(&self, wake: fn()) -> Poll<Self::Output>;
}

pub struct SocketRead<'a> {
    socket: &'a Socket,
}

impl SimpleFuture for SocketRead<'_> {
    type Output = Vec<u8>;

    fn poll(&mut self, wake: fn()) -> Poll<Self::Output> {
        if self.socket.has_data_to_read() {              // <-- Does syscall
            Poll::Ready(self.socket.read_buff())
        } else {
            self.socket.set_readable_callback(wake);     // <-- Does syscall
            Poll::Pending
        }
    }
}

// Real Future looks like this

pub trait Future {
    type Output;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;

    // &mut self -> Pin<&mut Self> : makes Self immovable (Guarantees that point wont move out from under us because of Pin)
    // wake: fn() -> cx: &mut Context<'_> : contains a Waker(they called it context, because maybe in future they could be more that that)
    // For now context is just a Waker but with different name!
}