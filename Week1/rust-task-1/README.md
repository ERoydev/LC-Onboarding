
# 🦀 Task Executor Library
A lightweight, multithreaded task executor built in Rust using std::thread. Inspired by Python's Celery, this library allows users to submit and run asynchronous tasks (Futures) across a pool of worker threads.

# 🚀 What It Does
This crate provides an easy-to-use API for executing async tasks (Futures) in a background thread pool. It works similarly to Python's Celery, but entirely in Rust — no external dependencies like Tokio or async-std are required.

# ✅ Features
Run async tasks on a multithreaded executor

Built using std::thread and Rust channels — no async runtime required

Efficient and simple: ideal for lightweight background job handling

Works well in no_std environments (if you're targeting embedded)

# 🧠 How It Works
You submit a Future to the executor

The executor schedules it onto a thread from the worker pool

The worker runs the task to completion

Ideal for background jobs, processing queues, or offloading work from the main thread
 
# Explanation of my implementation

## 🛜 I have used `Proxy` module used to be like mediary between the `user` and the `task_executor`.
- Proxy applies rate-limiting strategy
- My executor can accept 5 jobs per second.
- This means that every second user can send tasks to the executor where they will wait in the queue for free worker.
  
```rust
pub struct Proxy {
    rate_limit_per_sec: usize, // rate-limit_per_second
    slots: Vec<Instant>,
    executor: AsyncExecutor,
}
```

I have introduced the concept for slots
```rust
What are slots:
    - Slot is like a table with cups -> One table can hold up to 5 cups per second. Meaning a cup is delivered for 1 second.
    - After cup time exceed 1 second i can remove it from the table and 1 slot is freed.
    - I take element from the queue and put on the free table slot.
```

I have used infinite loop so when a task is sended it waits in the loop till slot space is freed (which happens every second)

## ✈️ Then is the executor called `AsyncExecutor`
Used to accept tasks, spawn threads(workers), keep metrics of task results(failed, total_tasks_executed ..), creates the channel for communication.
```rust
pub struct AsyncExecutor {
    // Accepts tasks (async fn, futures)
    // 5 jobs/sec rate limit
    // Concurrencty
    // Handles shutdowns, all tasks are (completed, canceled)
    stop_flag: Arc<AtomicBool>, // Use to force stop all threads
    workers_state: Arc<Mutex<WorkerStateTracker>>,
    metrics: Arc<Mutex<MetricsReport>>, // Store metric values -> Using Arc and Mutex because my threads will update this value in parallel and this can cause error
    worker_handles: Arc<Mutex<Vec<JoinHandle<()>>>>, // I use this to track running tasks and ensure they are waited instead of application shut down when main() finish => a common problem with std::threads
    sender: Option<Sender<Task>>, // Since i want to use one channel and i need to safe my sender address to be able to send from many scopes 
}
```

- When user initialize the a `Proxy` instance the `Proxy` creates an instance of this executor.
- When this executor is initialized it creates a channel and spawn_workers which are calculated for 3/4 for total CPU cores the machine has.
- Proxy sends tasks to the workers using .delay() from `AsyncExecutor` this method is responsible to send task to workers using the channel.
- In `spawn_workers` method i have decided to create Custom Executor using `Future's .poll()` method because it gives me full control when to stop executing a job.
- In threads i also have timeout implemented so when the task took longer than 5 seconds it is terminated and counted as failed task.
- I have also very important method called `.wait_all()` which user must use after he is done sending tasks it `joins` all the thread handlers in order to make the program to wait till all threads finalize their task execution. If user doesn't use this method there is a chance that his program will finish executing before threads are finished, causing unexpected behaviour.
- My running `threads` are like a `workers pool `each listening to the same channel and if worker is free(not executing at the moment) it takes task from channel and executes it.
  
# Workflow
- The user sends `Future` task to my Proxy
- Then my proxy applies the rate-limiting strategy sending tasks to `AsyncExecutor`
- The task waits for a free thread(worker) in the channel as a message.
- Worker takes the task goes in a infinite loop till Ready or reach 5 seconds execution time.

## Example of a valid futures
Here is a visual representation of what is future. In rust future is like a Promise in JavaScript the function is Future until it is .await to return its result
```rust
async fn send_email() {
    println!("Sending an email....");
    Delay::new(Duration::from_secs(1)).await;
    println!("Email sended successfully!")
}


fn fetch_data() -> impl Future<Output = ()> {
    async {
        println!("Satoshi greets you...");
        Delay::new(Duration::from_secs(1)).await;
        println!("Satoshi greeted you!")
    }
}
```


# Visual Code Example Of How To Use It

```rust
fn main() {
    // Concurrent tasks in parallel is the idea     
    let mut executor = Proxy::new();

    // .task() sends the future(!You should send only Futures) to the task executor
    // as First parameter you send your Future function as a second you send the priority(High, Medium, Low) or None if you dont want Priority => Priority::None
    executor.task(send_email(), Priority::High);
    executor.task(send_email(), Priority::None);
    executor.task(send_email(), Priority::High);
    executor.task(send_email(),  Priority::High);
    executor.task(send_ethers(), Priority::Medium);
    executor.task(send_ethers(), Priority::Low);
    executor.task(send_ethers(), Priority::Low);
    executor.task(send_ethers(), Priority::None);
    executor.task(send_email(), Priority::None);
    executor.task(send_email(), Priority::None);
    executor.task(send_email(), Priority::None);
    executor.task(send_email(), Priority::None);

    executor.task(task_with_parameters(String::from("John"), 24, String::from("John@gmail.com")), Priority::None);

    // This Function should be called u have finished sending tasks.
    // !IMPORTANT => if you forget to await_completion() your program can finish before threads finalize.
    executor.await_completion();
    
    // Metrics should be called only after .await_completion() func when the program have finalized all thread operations.
    executor.metrics();

    executor.force_shutdown(); // Shutdowns all threads from running allowing you to create new executor.
    drop(executor); // Drop executor instance if you are working in the same scope otherwise rust ownership rules will do it for you
    
    let mut executor = Proxy::new();

    executor.task(send_email(), Priority::None);

    executor.await_completion();

    executor.metrics();
}

```

# Running Tests
```rust
// Unit Tests
cargo test --lib

// Integration Tests
cargo test --test integration_tests
```

# Important!
- Dont use std::thread::sleep() in Async Futures it blocks the entire thread
        - Sleep runs when the future is polled
        - blocks the entire thread
        - Executor(custom loop) freezes and can't check for timeouts

- For simplication to mock longer tasks please use futures_timer::Delay()
    - Delay::new(Duration::from_secs(3)).await;

`Use functions that only yields, not blocking.`

- ❗ Do not use std::thread::sleep() inside async code or futures.
It blocks the thread, prevents other tasks from running, and breaks timeout logic.
Instead, use non-blocking timers like futures_timer::Delay or tokio::time::sleep() that return Poll::Pending and wake the task when ready.

# Note
Ignore the learning_code folder since its just for me
