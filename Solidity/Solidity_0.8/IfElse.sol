// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract IfElse {
    function example(uint _x) external pure returns (uint) {
        if (_x < 10) {
            return 1;
        } else if (_x < 20) {
            return 2;
        } 
        return 3;  
    }

    function ternary(uint _x) external pure returns (uint) {
        return _x < 10 ? 1 : 2; // if true return 1 if false return 2 ...
    }
}