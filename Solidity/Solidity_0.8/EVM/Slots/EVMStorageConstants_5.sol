// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract EVMStorageConstants {
    // Constants and immutables dont't use storage
    // slot 0
    uint256 public s0 = 1;
    uint256 public constant X = 123; // The exmaple is that here these dont use and are not stored on storage slots
    address public immutable owner;
    // slot 1
    uint256 public s1 = 2;

    constructor() {
        owner = msg.sender;
    }

    function test_get_slots() public view returns (uint256 v0, uint256 v1) {
        assembly {
            v0 := sload(0)
            v1 := sload(1)
        }
    }


}