// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// require, revert, assert
// - gas refund, state updates are reverted
// custom error - save gas

contract Errors {
    function testRequire(uint _i) public pure {
        require(_i <= 10, "i > 10"); // This is validation logic 
    }

    function testRevert(uint _i) public pure {
        // This is the same as require
        if (_i > 10) {
            // This is practical if this is nested in many nested if statements and only then revert is better option than require
            revert("i > 10");
        }
        // Example
        if (_i > 1) {
            if (_i > 2) {
                if (_i > 10) {
                    revert("i > 10");
                }
            }
        }
    }

    uint public num = 123; 
    // So for example this should be Not modified
    // But later in the code i accidentaly update num and when assert comes i catch the error
    // When error is thrown there will be a gas refund and state updates are reverted

    function testAssert() public view {
        assert(num == 123);
    }
    
    function foo() public {
        // accidentally update num
        num += 1;
    }


    // CUSTOM ERROR
    error MyError(address caller, uint i);

    function testCustomError(uint _i) public view {
        if (_i > 10) {
            revert MyError(msg.sender, _i);
        }
    }
}