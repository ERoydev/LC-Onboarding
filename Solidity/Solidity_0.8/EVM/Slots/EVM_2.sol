// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMStoragePackedSlotBytes {
    // State Variables that are less than 32 bytes will be packed into a single slot
    // slot 0 (packed right to left)
    bytes4 public b4 = 0xabababab;
    bytes2 public b2 = 0xcded;
    // This means these two State Variables will be packed into one slot

    // If i want to update the first or the second State Variables i need to create bit masking
    // Example: 0x0000000000000000000000000000000000000000000000000000cdedabababab
    // Masking: 0xffffffffffffffffffffffffffffffffffffffffffffffffffff0000ffffffff -> This is the bitmask

    function get() public view returns (bytes32 b32) {
        assembly {
            b32 := sload(0)
        }
    }
}

contract BitMasking {
    // |       256 bits
    // 000 ... 000 | 111 ... 111
    //             | 16 bits
    function test_mask() public pure returns (bytes32 shifted, bytes32 mask) {
        assembly {
            // 000 ... 001 | 000 ... 000 -> shifted i put 1 on 16 bit 
            // 000 ... 000 | 111 ... 111 -> mask - i 
            shifted := shl(16, 1) // I put 1 at bit 16
            // 0x0000000000000000000000000000000000000000000000000000000000010000
            mask := sub(shifted, 1) // All lower 16 bits become 1 in hex is `f`
            // 0x000000000000000000000000000000000000000000000000000000000000ffff
        }
    }
        
    function test_shift_mask() public pure returns (bytes32 mask) {
        assembly {
            // 000 ... 000 | 111 ... 111 | 000 ... 000
            //             | 16 bits     | 32 bits
            mask := shl(32, sub(shl(16, 1), 1)) // I shift these `1` left with 32 bits
            // 0x0000000000000000000000000000000000000000000000000000ffff00000000
        }
    }

    function test_masking() public pure returns (bytes32 mask) {
        // 111 ... 111 | 000 ... 000 | 111 ... 000
        //             | 16 bits     | 32 bits
        assembly {
            mask := not(shl(32, sub(shl(16, 1), 1)))
            // I basically use not to revert this => `0x0000000000000000000000000000000000000000000000000000ffff00000000`
        }
    }
}