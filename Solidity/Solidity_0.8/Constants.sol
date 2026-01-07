// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract Constants {
    // Constants are fixed values. Overall they save gas when i try to axcess and read them
    address public constant MY_ADDRESS = 0xc0ffee254729296a45a3885639AC7E10F9d54979;
    uint public constant MY_UINT = 123;
}

contract Var {
    address public MY_ADDRESS = 0xc0ffee254729296a45a3885639AC7E10F9d54979;
}