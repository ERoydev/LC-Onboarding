// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMStorageDynamicArray {
    // slot of element = keccak256 (slot where array is declared)
    //                    + size of element * index of element

    //                  Formula = keccak256(slot) + size of element * index of element

    // keccak256(0) + 1 * 0, keccak256(0) + 1 * 1, keccak256(0) + 1 * 2 -> size of element is 1 because uint256 is 32 bytes
    uint256[] private arr = [11, 22, 33];

    // keccak256(1), keccak256(1), keccak256(1) + 1  => where each element is stored on slot
    //                             keccak256(1) + (0.5 * 2) == 1 -> 0.5 size of element, because the element is uint128 which is 16 bytes half of 32 bytes.
    uint128[] private arr_2 = [1, 2, 3];

    function test_arr(uint256 slot, uint256 i) public view returns (uint256 val, bytes32 b32, uint256 len) {
        bytes32 start = keccak256(abi.encode(slot));

        assembly {
            len := sload(slot)
            val := sload(add(start, i))
            b32 := val
        }
    }

}