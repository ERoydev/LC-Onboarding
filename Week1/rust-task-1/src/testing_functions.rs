use std::time::Duration;

use futures_timer::Delay;

pub async fn send_email() {
    println!("Sending an email....");
    Delay::new(Duration::from_secs(1)).await;
    println!("Email sended successfully!")
}

pub async fn send_birthday_present() {
    println!("Sending a birthday present");
    Delay::new(Duration::from_secs(1)).await;

    println!("Birthday present sended successfully!")
}

pub async fn send_ethers() {
    println!("Sending ethers");
    Delay::new(Duration::from_secs(6)).await;
    println!("Sending ethers successfull")
}

pub async fn task_with_parameters(name: String, age: i32, email: String) {
    println!("Name: {}, Age: {}, Email: {}", name, age, email);
    Delay::new(Duration::from_secs(1)).await;
    println!("Parameters applied successfully!")
}