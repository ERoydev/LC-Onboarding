

// CLOSURES IN RUST ====================
// Closures are anonymous functions which captures its environment => if i have closure inside main() closure have access to every variable defined in main()
// 1. Borrowing (&T)
// 2. Mutable Borrowing (&mut T)
// 3. Moving (T) the closure takes ownership of the variable => 'move ||' syntax

/*
    All Closures implement one of the 3 Fn traits
        - Fn() 
        - FnMut()
        - FnOnce() => Takes the ownership of variables inside the closures environment, can only be called once

    Remember that Regular Functions also implement these three Fn traits.
        - That means i can store normal function in my calculation field as well.
*/

fn simulated_expensive_calculation(intensity: u32) -> u32 {
    println!("Calculation slowly...");
    thread::sleep(Duration::from_secs(2));
    intensity
}


fn main() {
    let simulated_intensity = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_intensity, simulated_random_number);

}

// THE PROBLEM => every case execution
fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_result = simulated_expensive_calculation(intensity); // Execute in every case 

    if intensity < 25 {
        println!(
            "Today, do {} pushups!",
            expensive_result
        );
        println!(
            "Next, do {} situps!",
            expensive_result
        );
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
            // So the problem with this approach is that this fn executes the expensive_function in every case
            // But this is case where this expensive_function is not needed and executing it is performance issue
            // With Closure i can define my code and execute it only when it's necessary!!!! ------------
        } else {
            println!(
                "Today, run for {} minutes!",
                expensive_result
            );
        }
    }
}

// FIRST SOLUTION => Still bad
fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_closure = |num| { // Here i define the closure here which is identical to my expensive function above
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    }; // Here i do not store the result of this expensive calucation i just store the closure itself


    // The logic to define the function and then use it when it is needed is good
    // Perhaps i have another problem in one if statement i call this function twice
    if intensity < 25 {
        println!(
            "Today, do {} pushups!",
            expensive_closure(intensity)
        );
        println!(
            "Next, do {} situps!",
            expensive_closure(intensity)
        );
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!(
                "Today, run for {} minutes!",
                expensive_closure(intensity)
            );
        }
    }
}

// RULE IN CLOSURE => The first time cast in a closure will be the concrete type that this closure expects bellow\
fn some_example() {
    let expensive_closure = |num: u32| -> u32 { // Here i define the closure here which is identical to my expensive function above
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    }; // Here i do not store the result of this expensive calucation i just store the closure itself
    
    let example_closure = |x| x;
    let s = example_closure(String::from("Hello")); // Here is my first type passed in a closure so this becomes the concrete type
    let n = example_closure(5); // That is why this will fail on compiling

}    

// SECOND SOLUTION => using cache memoization pattern =====================================

// Some kind of memoization pattern
// In order to define struct, enums or even function parameters that use closures we need to use generics and traits bounds

struct Cacher<T> // Generic T is like a placeholder for types => Can be used with multiple types
where // is used to specify requirements for the generic type parameters
    T: Fn(u32) -> u32, // Trait bound that requires T to implement this trait
{
    calculation: T, // Holds the closure
    value: Option<u32>, // Holds the result of my closure
}

/* Have in mind that here i have hard coded types which i can make fully dynamic with Generics but i need to implement some more Traits

    // impl<T> Cacher<T>
    // where
    //     T: Eq + Hash + Copy, // added trait bounds
    // {
    //     fn new() -> Cacher<T> {
    //         Cacher { value: HashMap::new() }
    //     }

    //     fn insert_value(&mut self, arg: T, calculation_result: T) {
    //         self.value.insert(arg, calculation_result);
    //     }
    // }

*/

    impl<T> Cacher<T>
where 
    T: Fn(u32) -> u32,
{
    fn new(calculation: T) -> Cacher<T> {
        Cacher { 
            calculation,
            value: None, // None when initialized of course
        }
    }

    fn value(&mut self, arg: u32) -> u32 {
        // In other words when i already have value i return if if i dont have i set it so i will stop making worthless calculations
        match self.value {
            Some(v) => v, // I can store Hasmap instead of just one value so i can have better solution
            None => {
                let v = (self.calculation)(arg); 
                self.value = Some(v);
                v
            }
        }
    }

    // Optimized using HashMap to work with multiple parameters
    fn value(&mut self, arg: u32) -> u32{
        let value_exists_for_this_key = self.value.get(&arg);
        match value_exists_for_this_key {
            Some(v) => *v,
            None => {
                let calculation_result = (self.calculation)(arg);
                self.value.insert(arg, calculation_result);
                calculation_result
            }
        }
    }

}


fn generate_workout(intensity: u32, random_number: u32) {
    let mut cached_result = Cacher::new(|num| {
        println!("calculating slowly...");
        thread::sleep(Duration::from_secs(2));
        num
    }); 

    if intensity < 25 {
        println!(
            "Today, do {} pushups!",
            cached_result.value(intensity)
        );
        println!(
            "Next, do {} situps!",
            cached_result.value(intensity)
        );
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!(
                "Today, run for {} minutes!",
                cached_result.value(intensity)
            );
        }
    }
}
