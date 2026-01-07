



// First Example of simple data transfer between threads using channel
// mpsc stands for Multi Producer Single Consumer (Fifo Queue)
// use std::sync::mpsc

fn main() {
    // Transmitter sends data -> receiver grabs and give to the thread
    let (tx, rx) = mpsc::channel();


    thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap(); // Send from this thread the data 'val'
    });

    let received = rx.recv().unwrap(); // Receive the data into the main thread
    println!("Got: {}", received);
}


// Another example sending multiple data to the receiver and threating rx as an iterator here
fn main() {
    // Transmitter sends data -> receiver grabs and give to the thread
    let (tx, rx) = mpsc::channel();
    
    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread")
            ];
            
            for val in vals {
                tx.send(val).unwrap();
                thread::sleep(Duration::from_secs(1));
            }
            // Here everything drops becase i have no code and the iterator for rx ends here
        });
        
    // not calling the .recv() anymore
    // Using the 'rx' as an iterator
    // When the channel is closed, the loop will exit
    for received in rx {
        println!("Got: {}", received); 
    }
}

// Same example as the above one but here i send from two transmitters to one receiver and it works
fn main() {
    // Transmitter sends data -> receiver grabs and give to the thread
    let (tx, rx) = mpsc::channel();

    let tx1 = tx.clone(); // Clone to create another transmitter

    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread")
        ];

        for val in vals {
            tx1.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
        // Here everything drops becase i have no code and the iterator for rx ends here
    }); 

    thread::spawn(move || {
        let vals = vec![
            String::from("more"),
            String::from("messages"),
            String::from("for"),
            String::from("you"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
        // Here everything drops becase i have no code and the iterator for rx ends here
    }); 

    // not calling the .recv() anymore
    // Using the 'rx' as an iterator
    // When the channel is closed, the loop will exit
    for received in rx {
        println!("Got: {}", received); 
    }
}


// SHARED STATE CONCURRENCY =====================+>
