
use crate::{core::executor::AsyncExecutor, priority::priority::Priority, core::types::Task};

use super::{base_rate_limiter::BaseRateLimiter, slots::Slots, types::SlotsVector};

pub struct SlotRateLimiter {
    rate_limit_per_sec: usize,
    slots: SlotsVector,
}

impl SlotRateLimiter {
    pub fn new(rate_limit_per_sec: usize) -> SlotRateLimiter {
        SlotRateLimiter {
            rate_limit_per_sec,
            slots: Vec::new()
        }
    }

    fn add_task_to_slot(&mut self, current_slot: Slots) {
        self.slots.push(current_slot)
    }

    fn remove_task_from_slot(&mut self, index_of_slot_to_remove: usize) {
        self.slots.remove(index_of_slot_to_remove);
    }

    fn free_slot_space(&mut self) {
        self.slots.retain(|slot| slot.get_current_timestamp().elapsed().as_secs() < 1); // Keep slots that have less seconds that 1: Similar like .filter() type of methods
        // Same as the down bellow, 

        // for (idx, slot) in self.slots.iter().enumerate() {
        //     let time_passed = slot.elapsed().as_secs();

        //     if time_passed >= 1 {
        //         self.slots.remove(idx);
        //     }
        // }
    }

    pub fn slot_limited(&mut self, priority: Priority, executor: AsyncExecutor, fut: Task) {
        let mut current_slot = Slots::new(&priority);
        let min_idx_value_to_remove_from_slots = Slots::check_priority(&mut current_slot, &priority, &mut self.slots);

        match min_idx_value_to_remove_from_slots {
            // If i have returned idx this means i should remove the lowest priority from the slots
            Some(idx) => {
                if self.slots.len() >= self.rate_limit_per_sec {
                    // Remove the task from the slot only if slow is already full
                    self.remove_task_from_slot(idx);
                }
            }
            None => {}
        }

        // Here before the loop i remove_task_from_slot() if i have priority in self.slots that is lower than my current received one
        // So i have free space in my slots for a new one, otherwise i will not have and the loop is going to wait till slot is freed.
        loop {  
            // println!("SLOTS LEN: {}", self.slots.len());
            if self.slots.len() < self.rate_limit_per_sec {
                self.add_task_to_slot(current_slot);

                // Here i can send the task
                self.delay_task_after_limit_pass(executor, fut);
                break;
            } else {
                // Rate Limit reached wait till one second pass and free slot spaces
                // fail_gracefully(crate::error_handler::ExecutorError::RateLimitExceeded, "Rate-Limit reached, your tasks are waiting till space for execution is freed.");
                self.free_slot_space();
            }              
        }
    }
}

impl BaseRateLimiter for SlotRateLimiter {
    fn delay_task_after_limit_pass(&self, executor: AsyncExecutor, fut: Task) {
        let task = Box::pin(fut); // Executioner expects known memory size at compilation, since i dont know it i store to the heap
        executor.delay(task); // Send to executioner 
    }
}


#[cfg(test)]
mod test {
    use std::{thread::sleep, time::Duration};

    use crate::priority::priority::Priority;

    use super::*;

    #[test]
    fn test_new_should_return_slot_rate_limiter_instance() {
        let default_rate_limit = 5;
        let rate_limiter = SlotRateLimiter::new(default_rate_limit);
        // let executor = AsyncExecutor::new();

        assert_eq!(rate_limiter.rate_limit_per_sec, default_rate_limit);
        assert_eq!(rate_limiter.slots, vec![]);
        
        assert!(true)
    } 

    #[test]
    fn test_add_task_to_slots_should_be_valid() {
        let mut rate_limiter  = SlotRateLimiter::new(5);
        let task_slot = Slots::new(&Priority::None);
        
        assert_eq!(rate_limiter.slots.len(), 0);

        rate_limiter.add_task_to_slot(task_slot.clone());
        assert_eq!(rate_limiter.slots.len(), 1);

        rate_limiter.add_task_to_slot(task_slot.clone());
        assert_eq!(rate_limiter.slots.len(), 2);
    } 

    #[test]
    fn test_free_slot_space_should_be_valid() {
        let mut rate_limiter = SlotRateLimiter::new(5);
        
        assert_eq!(rate_limiter.slots.len(), 0);

        let task_slot = Slots::new(&Priority::None);

        rate_limiter.add_task_to_slot(task_slot.clone());
        assert_eq!(rate_limiter.slots.len(), 1);

        rate_limiter.add_task_to_slot(task_slot.clone());
        assert_eq!(rate_limiter.slots.len(), 2);

        rate_limiter.add_task_to_slot(task_slot.clone());
        assert_eq!(rate_limiter.slots.len(), 3);

        rate_limiter.add_task_to_slot(task_slot.clone());
        rate_limiter.add_task_to_slot(task_slot.clone());
        rate_limiter.add_task_to_slot(task_slot.clone());
        rate_limiter.add_task_to_slot(task_slot.clone());

        sleep(Duration::from_secs(1));
        rate_limiter.free_slot_space();
        assert_eq!(rate_limiter.slots.len(), 0);

        rate_limiter.add_task_to_slot(task_slot.clone());
        assert_eq!(rate_limiter.slots.len(), 1);
    }

}