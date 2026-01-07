// Here i leave my code that i have written in order to learn the concepts that i need to finish this task


// THREAD SPAWN ===========================
fn main() {
    // let async_executor = AsyncExecutor::new();

    // let closure = vec![|| "Hello", || "Another"];
    
    let handle: JoinHandle<()> = thread::spawn(|| { // This run in parallel with the main thread of my program main() meaning the code inside main() run concurrently with the code inside the spawned thread
        // Creates a new thread and executes the closure(the code inside { ... } braces)

        // Here in other hand the code run in sequence
        for i in 1..10 {
            println!("Hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }

        for i in 1..5 {
            println!("Hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    // I need to use JoinHandle because when the main() thread ends the spawn thread is stopped no matter if it finished executing or not
    // So i need to allow this thread to finish execution
    // 1. I store the return value of spawn in a variable
    // 2. handle.join() makes the thread finish executing
    // 3. unwrap() because join returns Result<> type
    handle.join().unwrap(); 

    /*
    Calling .join() will block the thread currently running(the main thread) until the thread that .join() is called for (thread::spawn) is finished(terminated)
     */

}


// CLOSURE MOVE =========================
// When the closure need to take the ownership of value defined in its parent scope
fn main() {
    let v = vec![1, 2, 3];

    let error = thread::spawn(|| {
        // The problem here is that if the rust doesnt know when the 'v' vector will be dropped since i have two threads it could be dropped in main() thread, while my spawn thread is using it
        // That's why rust doesnt allow me to have a reference to v inside a closure
        println!("Here is a vector: {:?}", v);
    });

    // error.join().unwrap();


    // When i say 'move ||' i force the closure to take ownership of the values defined outside of the closure, that are used inside the closure
    // In other words if in closure exist a value that is borrowed it will take the ownership of it
    let correct = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });

    correct.join().unwrap();

}
