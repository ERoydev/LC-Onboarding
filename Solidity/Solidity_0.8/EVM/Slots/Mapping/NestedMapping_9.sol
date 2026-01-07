// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMNestedMapping {
    // mapping(key => value)
    // slot of value keccak256(key, slot where mapping is declared)
    // key0 => key1 => val

    // slot of value = keccak256(key1, keccak256(key0, slot where mapping is declared))

    // addr0 => addr1 => val
    //          keccak256(addr, keccak256(addr, 0))
    mapping(address => mapping(address => uint256)) public lecturer;

    mapping(address => mapping(uint256 => bool)) public map;
    address public constant ADDR_1 = address(1);
    address public constant ADDR_2 = address(2);
    address public constant ADDR_3 = address(3);

    constructor() {
        // My example
        map[ADDR_1][0] = true;
        map[ADDR_2][1] = false;
        map[ADDR_3][2] = true;

        // Lecturer example
        lecturer[ADDR_1][ADDR_2] = 11;
        lecturer[ADDR_2][ADDR_3] = 22;
        lecturer[ADDR_3][ADDR_1] = 33;
    }

    function test_mapping(address key0, uint256 key1) public view returns(uint256 v) {
        // bytes32 slot_v = keccak256(abi.encode(key, tokenId, uint256(0)));
        bytes32 slot_v = keccak256(abi.encode(key1, keccak256(abi.encode(key0, uint256(0)))));

        assembly {
            v := sload(slot_v)
        }
    }

    function test_nested_mapping(address key0, address key1) public view returns (uint256 v) {
        bytes32 s0 = keccak256(abi.encode(key0, uint256(0)));
        bytes32 s1 = keccak256(abi.encode(key1, s0));

        assembly {
            v := sload(s1)
        }
    }

}