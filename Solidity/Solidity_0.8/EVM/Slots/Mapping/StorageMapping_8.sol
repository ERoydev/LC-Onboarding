// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMStorageMapping {
    // mapping(key => value)
    // slot of value keccak256(key, slot where mapping is declared)

    // this is on slot 0
    mapping(address => uint256) public map;

    address public constant ADDR_1 = address(1);
    address public constant ADDR_2 = address(2);
    address public constant ADDR_3 = address(3);

    constructor() {
        map[ADDR_1] = 11;
        map[ADDR_2] = 22;
        map[ADDR_3] = 33;
    }

    // slot of value = keccak256(key, slot where mapping is declared)
    function test_mapping(address key) public view returns(uint256 v) {
        bytes32 slot_v = keccak256(abi.encode(key, uint256(0)));

        assembly {
            v := sload(slot_v)
        }
    }

}