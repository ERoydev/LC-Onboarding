// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract GasGolf {
    // start - 50782 gas
    // use calldata
    // load state variables to memory
    // short circuit
    // loop increments
    // cache array length
    // load array elements to memory
    // latest gas - 47231 gas

    uint private total;

    // [1, 2, 3, 4, 5, 100]
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        uint len = nums.length; // Cache array length, instead of always checking on every iteration nums.length, this saves some gas

        for (uint i = 0; i < len; ++i) {
            uint currNum = nums[i];

            if (currNum % 2 == 0 && currNum < 99) {
                _total += currNum;
            }
        }

        total = _total;
    }
}

/*
Summary:
    - 1. the parameter nums was `memory` and making it `calldata` optimizes good.

    - 2. there was the problem that i access state variable and increment in the loop multiple times.
        I solved by creating memory variable inside func and then update state variable only once.

    - 3. I wass acessing nums[i] multiple times making computations before the if checks that may be useless if if statement fails.
            isEven = nums[i] % 2 == 0
            isLessThan99 = nums[i] < 99
        - These two computation are useless if the `if statement` fails on the first part
            if (isEven && isLessThan99) {....} 
        - Instead we do
            if (nums[i] % 2 == 0 && nums[i] < 99) {...} -> if nums[i] not even i will not do the next computation.

    - 4. For loops change to pre increment instead of increment what does that mean:
        ++i pre-increment means: increment i first, then use it.
        i++ post-increment (what i += 1 is compiled into, roughly) means:
            make a copy of i
            increment i
            return the original copy.
        - In other words:
            ++i only increments, no extra copy.
            i += 1 (or i++) creates a temporary variable, then increments.

    - 5. Cache array length instead of checking nums.length inside the for loop i cache it and use its already computed length

    - 6. Like in step `3.` we can optimize by setting nums[i] into a variable like currNum = nums[i] and the use instead of accessing every time.
*/