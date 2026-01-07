// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Counter {
    // When i declare State Variable as public i will have read access after this contract is deployed
    uint public count = 0;

    function increment() external {
        // This is not 'pure' or 'view' function becase it modifies State Variable
        count += 1;
    }

    function decrement() external {
        count -= 1;
    }
}