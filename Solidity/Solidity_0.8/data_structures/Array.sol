// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// Array - dynamic or fixed size
// Initialization
// Insert (push), get, update, delete, pop, length
// Creating array in memory
// Returning array from function

contract Array {
    uint[] public nums = [1, 2, 3]; // Dynamic array
    uint[3] public fixedNums = [4, 5, 6]; // Fixed sized array of size 3 => meaning the size cannot be changed(cannot shrink or grow). It is initialized with zeros

    function examples() external {
        nums.push(4); // [1, 2, 3, 4] => push in the end of the array
        uint x = nums[1]; // Access value using index
        nums[2] = 777; // Update value at a specified index
        delete nums[0]; // Delete value from an array.
        nums.pop(); // Removes last element from the array
        uint len = nums.length;

        // create array in memory
        uint[] memory myArray = new uint[](5); // Array in memory has to be fixed size (5) in my case
        myArray[1] = 123;
    } 

    function returnArray() external view returns (uint[] memory) {
        // Tipically is not recommended to return an array in my case it is dynamic array meaning if its too big this will have huge gas fees.
        return nums;
    }
}