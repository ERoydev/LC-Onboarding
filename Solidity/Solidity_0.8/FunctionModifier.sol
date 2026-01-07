// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// Function modifier - reuse code before and / or after function
// Basic, inputs, sandwich

contract FunctionModifier {
    bool public paused;
    uint public count;

    function setPause(bool _paused) external {
        paused = _paused;
    }

    // It gives me way of reuse some validation checks in my functions
    modifier whenNotPaused() {
        require(!paused, "paused");
        _; // '_' tells solidity to call the actual function that this modifier wrapps !
    }

    function inc() external whenNotPaused {// Here i wrap with this modifier and this will check before execution for some validation check.
        count += 1;
    }

    function dec() external whenNotPaused {
        count -= 1;
    }

    modifier cap(uint _x ) {
        require(_x < 100, "x >= 100");
        _;
    }

    // Here i have multiple modifiers applied to this function
    function incBy(uint _x) external whenNotPaused cap(_x) {
        count += _x;
    }

    modifier sandwich() {
        // Code before
        count += 10;
        _; // execution
        // Code after execution
        count *= 2;
    }

    function foo() external sandwich {
        count += 1;
    }
}