// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
The problem:
    - when i call functions in solidity i have to remember and type and the same order of the inputs
Solution:
    - I can use key value pairs
*/

contract XYZ {
    function someFuncWithManyInputs(uint x, uint y, uint z, address a, bool b, string memory c) public pure returns (uint) {
        
    }

    function callFunc() external pure returns (uint) {
        return someFuncWithManyInputs(1, 2, 3, address(0), true, "some c");
    }
    // SOLUTION
    function callFuncWithKeyValues() external pure returns (uint) {
        return someFuncWithManyInputs({
            x: 1,
            y: 2,
            z: 3,
            a: address(0),
            b: true,
            c: "C"
        });
    }
}