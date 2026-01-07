

fn main() {
    let m = Mutex::new(5);
    

    // The idea is that nobody else can mutate this at the time we are
    {
        // use the `lock()` to acquire a lock
        let mut num = m.lock().unwrap();
        // get inside the point using `*` deref
        *num = 6;
    } // So here MutexGuard drop `unlock the data` so others can use it after this block scope
    
    println!("m = {:?}", m);
}

fn main() {
    let counter = Arc::new(Mutex::new(0)); // Arc helps me work around rusts ownership rules to be able to share data between threads
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap(); // Because here counter will drop after the first iteration becase move takes ownership, running to compile error

            *num += 1;
        });
        handles.push(handle)
    }

    for handle in handles {
        // Spawning a thread doesn't mean it finishes before main() ends
        // Thats why i use .join() -> waits for that thread to finish before continuing
        handle.join().unwrap();
        // Without join() i have the common problem that main() ends before my thread::spawn is finished
    }

    println!("Result: {}", *counter.lock().unwrap());
}