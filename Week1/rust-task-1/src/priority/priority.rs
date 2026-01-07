

#[derive(Debug, Clone, PartialEq)]
pub enum Priority {
    None,
    Low,
    Medium,
    High,
}

impl Priority {
    pub fn to_value(&self) -> u8 {
        match self {
            Priority::None => 0,
            Priority::Low => 1,
            Priority::Medium => 2,
            Priority::High => 3,
        }
    }
}
