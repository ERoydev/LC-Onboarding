

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct MetricsReport {
    tasks_count: u32,
    tasks_failed: u32,
    total_execution_time: u32,
}

impl MetricsReport {
    pub fn new() -> MetricsReport{
        MetricsReport { tasks_count: 0, tasks_failed: 0, total_execution_time: 0 }
    }

    // Using Getters and Setters without exposing MetricsReport fields

    pub fn increment_task_count(&mut self) {
        self.tasks_count += 1;
    }

    pub fn increment_tasks_failed(&mut self) {
        self.tasks_failed += 1;
    }

    pub fn increment_total_execution_time(&mut self, execution_time: u32) {
        self.total_execution_time += execution_time;
    }

    pub fn get_average_execution_time(&self) -> u32 {
        // Beware of division by zero problem
        if self.total_execution_time > 0 {
            let avg_time = self.total_execution_time / (self.tasks_count - self.tasks_failed); // I dont want to include failed tasks into avg_execution_time since it was not executed
            avg_time
        } else {
            0
        }
    }

    pub fn metrics_info(&self) {
        let report_message = format!("\n- Currently the program has runned {} tasks.\n- Which of {} tasks has failed.\n- With average execution time of {}s \n", self.tasks_count, self.tasks_failed, self.get_average_execution_time());
        println!("{}", report_message);
    }

    pub fn get_tasks_count(&self) -> u32 {
        self.tasks_count
    }

    pub fn get_tasks_failed(&self) -> u32 {
        self.tasks_failed
    }

}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_initial_values() {
        let report = MetricsReport::new();
        assert_eq!(report.get_tasks_count(), 0);
        assert_eq!(report.get_tasks_failed(), 0);
        assert_eq!(report.get_average_execution_time(), 0);
    }

    #[test]
    fn test_increment_task_count() {
        let mut report = MetricsReport::new();
        report.increment_task_count();
        assert_eq!(report.get_tasks_count(), 1);
    }

    #[test]
    fn test_increment_tasks_failed() {
        let mut report = MetricsReport::new();
        report.increment_tasks_failed();
        assert_eq!(report.get_tasks_failed(), 1);
    }

    #[test]
    #[should_panic]
    fn test_increment_total_execution_time_while_task_count_is_zero_should_fail() {
        let mut report = MetricsReport::new();

        report.increment_total_execution_time(100);

        report.get_average_execution_time();
    }

    #[test]
    fn test_average_execution_time_excludes_failed_tasks() {
        let mut report = MetricsReport::new();

        // Add 3 tasks
        report.increment_task_count(); 
        report.increment_total_execution_time(100);

        report.increment_task_count(); 
        report.increment_tasks_failed();

        report.increment_task_count(); 
        report.increment_total_execution_time(200);

        assert_eq!(report.get_tasks_count(), 3);
        assert_eq!(report.get_tasks_failed(), 1);
        assert_eq!(report.get_average_execution_time(), 150);
    }

    #[test]
    fn test_average_execution_time_no_successful_tasks() {
        let mut report = MetricsReport::new();
        report.increment_task_count();
        report.increment_tasks_failed();

        assert_eq!(report.get_average_execution_time(), 0);
    }

    #[test]
    fn test_get_tasks_count_should_return_u32() {
        let report = MetricsReport::new();
        
        let tasks_count: u32 = report.get_tasks_count();

        assert_eq!(tasks_count, 0);
    }

    #[test]
    fn test_get_tasks_failed_should_return_u32() {
        let report = MetricsReport::new();
        
        let tasks_failed: u32 = report.get_tasks_failed();

        assert_eq!(tasks_failed, 0);
    }
}
