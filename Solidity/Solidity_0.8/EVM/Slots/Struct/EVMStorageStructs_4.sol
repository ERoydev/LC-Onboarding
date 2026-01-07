// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract EVMStorageStruct {
    struct SingleSlot {
        uint128 x;
        uint64 y;
        uint64 z;
    }

    struct MultipleSlots {
        // slot 1
        uint256 a;
        // slot 2
        uint256 b;
        // slot 3
        uint256 c;
    }

    // slot 0
    SingleSlot public single = SingleSlot({x: 1, y: 2, z: 3});
    // slot 1, 2, 3
    MultipleSlots public multi = MultipleSlots({a: 11, b: 22, c: 33});

    function test_get_single_slot_struct() public view returns(uint128 x, uint64 y, uint64 z) {
        assembly {
            let s := sload(0)
            // z  | y  | z
            // 64 | 64 | 128 bits
            // s = 32 bytes = 256 bits
            // x            = 128 bits
            x := s // When i assign the first 128 bits will be loaded, the rest will not because x is uint128 bits
            y := shr(128, s) 
            z := shr(192, s)
        }
    }

    function test_get_multiple_slots_struct() public view returns(uint256 a, uint256 b, uint256 c) {
        assembly {
            a := sload(1)
            b := sload(2)
            c := sload(3)
        }
    }
}