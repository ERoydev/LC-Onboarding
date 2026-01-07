// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMMappingDynamicArray {
    // mapping(key => dynamic array(32 bytes elements))

    // mapping(key => 32 bytes)
    // slot of array element = keccak256(key, slot)

    // dynamic array of 32 bytes elements
    // slot of array element = keccak256(slot) + index

    // mapping -> array
    // slot where the dynamic array is declared = keccak256(key, slot)

    // slot of array element = keccak256(keccak256(key, slot of map)) + index
 
    mapping(address => uint256[]) public map;

    address public constant ADDR_1 = address(1);
    address public constant ADDR_2 = address(2);

    constructor() {
        map[ADDR_1].push(11);
        map[ADDR_1].push(22);
        map[ADDR_1].push(33);
        map[ADDR_2].push(44);
        map[ADDR_2].push(55);
        map[ADDR_2].push(66);
    }

    function test_map_arr(address addr, uint256 i) public view returns (uint256 v, uint256 len) {

        // slot of array element = keccak256(keccak256(key, slot of map)) + index

        uint256 map_slot = 0; // because map is declared on `slot 0`
        bytes32 map_hash = keccak256(abi.encode(addr, map_slot));
        bytes32 arr_hash = keccak256(abi.encode(map_hash));

        assembly {
            len := sload(map_hash)
            v := sload(add(arr_hash, i)) // + index operation to get specific element from that array
        }
    }
}