

#[cfg(test)]
mod integration_tests {
    use std::time::Duration;

    use futures_timer::Delay;
    use rust_task_1::{core::proxy::Proxy, priority::priority::Priority};

    pub async fn send_email() {
        println!("Sending an email....");
        Delay::new(Duration::from_secs(3)).await;
        println!("Email sended successfully!")
    }
    
    #[test]
    fn test_proxy_full_workflow() {
        let mut executor = Proxy::new();
        executor.task(send_email(), Priority::None);
        executor.task(send_email(), Priority::None);
        executor.task(send_email(), Priority::None);
        executor.task(send_email(), Priority::None);
        executor.task(send_email(), Priority::None);
        executor.task(send_email(), Priority::Low);

        executor.await_completion();
        executor.metrics();
        executor.force_shutdown();

        let mut executor = Proxy::new();
        executor.task(send_email(), Priority::None);
        executor.task(send_email(), Priority::None);
        executor.task(send_email(), Priority::Low);

        executor.await_completion();
        executor.metrics();
        executor.force_shutdown();
        assert!(true);
    }

}
