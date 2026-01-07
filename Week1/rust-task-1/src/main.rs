use std::time::Duration;
use futures_timer::Delay;
use rust_task_1::{priority::priority::Priority, core::proxy::Proxy};


fn main() {
    // Concurrent tasks in parallel is the idea     
    // let mut executor = Proxy::new();

    // // .task() sends the future(!You should send only Futures) to the task executor
    // // as First parameter you send your Future function as a second you send the priority(High, Medium, Low) or None if you dont want Priority => Priority::None
    // executor.task(send_email(), Priority::High);
    // executor.task(send_email(), Priority::None);
    // executor.task(send_email(), Priority::High);
    // executor.task(send_email(),  Priority::High);
    // executor.task(send_ethers(), Priority::Medium);
    // executor.task(send_ethers(), Priority::Low);
    // executor.task(send_ethers(), Priority::Low);
    // executor.task(send_ethers(), Priority::None);
    // executor.task(send_email(), Priority::None);
    // executor.task(send_email(), Priority::None);
    // executor.task(send_email(), Priority::None);
    // executor.task(send_email(), Priority::None);

    // executor.task(task_with_parameters(String::from("John"), 24, String::from("John@gmail.com")), Priority::None);

    // // This Function should be called u have finished sending tasks.
    // // !IMPORTANT => if you forget to await_completion() your program can finish before threads finalize.
    // executor.await_completion();
    
    // // Metrics should be called only after .await_completion() func when the program have finalized all thread operations.
    // executor.metrics();

    // executor.force_shutdown(); // Shutdowns all threads from running allowing you to create new executor.
    // drop(executor); // Drop executor instance if you are working in the same scope otherwise rust ownership rules will do it for you
    
    // let mut executor = Proxy::new();

    // executor.task(send_email(), Priority::None);

    // executor.await_completion();

    // executor.metrics();
}



// Examples for futures
pub async fn task_with_parameters(name: String, age: i32, email: String) {
    println!("Name: {}, Age: {}, Email: {}", name, age, email);
    Delay::new(Duration::from_secs(4)).await;
    println!("Parameters applied successfully!")
}

pub async fn send_email() {
    println!("Sending an email....");
    Delay::new(Duration::from_secs(3)).await;
    println!("Email sended successfully!")
}

pub async fn send_birthday_present() {
    println!("Sending a birthday present");
    Delay::new(Duration::from_secs(2)).await;

    println!("Birthday present sended successfully!")
}

pub async fn send_ethers() {
    println!("Sending ethers");
    Delay::new(Duration::from_secs(6)).await;
    println!("Sending ethers successfull")
}


