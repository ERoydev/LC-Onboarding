/*
    RATE-LIMITING LOGIC

    This stays between the client and the executor
    Tipically user use .delay() pass his function inside the Executor then delay() sends the task via channel
    The purpose of this module is to limit how many tasks delay() should send to the channel per second

    Имаш rate limit = 5 задачи/секунда → това е максималният брой задачи, които можеш да стартираш в рамките на една секунда, дори и да имаш капацитет.
    I have rate limit = 5 tasks/second -> maximum tasks i can start in one second, even if i have 10 free workers

    - When user sends 20 tasks in once -> I accept them but i pass 5 per second on .delay() till slots are freed
    
    What are slots:
        - Slot is like a table with cups -> One table can hold up to 5 cups per second. Meaning a cup is delivered for 1 second.
        - After cup time exceed 1 second i can remove it from the table and 1 slot is freed.
        - I take element from the queue and put on the free table slot.
*/

use std::time::Instant;

use crate::priority::priority::Priority;


#[derive(Debug, Clone, PartialEq)]
pub struct Slots {
    priority: u8, // 0 = None, 1 = Low, 2 = Medium, 3 = High
    timestamp: Instant, // The time starts when the task is added to the slots, meaning it is accepted to be executed
    checked: bool, // When checked that means that i have task with lower priority in my slots so i need to replace it with this task.
}

impl Slots {
    pub fn new(priority: &Priority) -> Slots {
        Slots { priority: priority.to_value(), timestamp: Instant::now(), checked: false }
    }

    pub fn check_priority(current_slot: &mut Slots, priority: &Priority, slots_queue: &Vec<Slots>) -> Option<usize> {
        // This function will check the slot if i need to replace it with lower priority and it will return the idx of the lower priority slot
        // Otherwise it will do nothing

        let mut min_index_to_remove = None;
        let mut min_value = 10;

        if priority != &Priority::None && slots_queue.len() > 0 {
            for  (idx, slot) in slots_queue.iter().enumerate() {
                if slot.priority < min_value {
                    min_value = slot.priority;
                    min_index_to_remove = Some(idx);
                }
            }
            if current_slot.priority > min_value {
                current_slot.checked = true;
                return min_index_to_remove
            }
        }
        None
    }

    pub fn get_current_timestamp(&self) -> Instant {
        self.timestamp
    }
}
