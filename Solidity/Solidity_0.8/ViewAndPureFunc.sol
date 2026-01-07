// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// view -> read the blockchain state, but cannot modify it.
// pure -> does not read or modify the blockchain state, it only works with inputs and local variables (computational logic).

contract ViewAndPureFunctions {
    uint public num;

    // View function -> Doesn't modify or write anything to the blockchain. READS DATA FROM BLOCKCHAIN in this case reads a State Variable
    function viewFunc() external view returns (uint) {
        return num;
    }

    // Pure functions -> Read only function, doesnt modify anything on the blockchain or read any data from blockchain, just do some computations there
    function pureFunc() external pure returns (uint) {
        return 1;
    }

    function addToNum(uint x) external view returns (uint) {
        // It reads State Variable
        return num + x;
    }

     function add(uint x, uint y) external pure returns (uint) {
        // Pure function because;
        //  - It does not read any data from Stare Variable, smart contract or blockchain
        return x + y;
    }
}