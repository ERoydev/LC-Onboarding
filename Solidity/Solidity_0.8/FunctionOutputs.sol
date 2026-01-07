// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract FunctionOutputs {
    function returnMany() public pure returns (uint, bool) {
        return (1, true);
    }

    function named() public pure returns (uint x, bool b) {
        return (1, true);
    }

    function assigned() public pure returns (uint x, bool b) {
        x = 1;
        b = true;
    }

    function destructingAssignments() public pure {
        (uint x, bool b) = returnMany(); // Destructuring the outputs from a function that returns many
        (, bool _b) = returnMany(); // Thats how i take only the outputs that i want
    }
}