// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract DefaultValues {
    bool public b; // false default value
    uint public u; // 0 -> default
    int public i; // 0
    address public a; // 0x0000000000000000000000 -> type of default value of address
    bytes32 public b32; // 0x00000000000000000 seq of 64 zeroes 
}