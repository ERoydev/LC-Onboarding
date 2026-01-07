// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMStoragePakedSlot {
    // Data < 32 bytes are packed into a slot
    // Bit masking (how to create 111....111)
    // slot, offset

    // slot 0
    uint128 public s_a;
    uint64 public s_b;
    uint32 public s_c;
    uint32 public s_d;

    // slot 1
    // 20 bytes = 160 bits
    address public s_addr;
    // 96 bits more can fit into this slot
    uint64 public s_x;
    uint32 public s_y;


    function test_ssstore() public {
        assembly {
            let v := sload(0) // x0000000000000000000000000000000000000000000000000000000000000000

            // s_d | s_c | s_b | s_a => "EVM packs variables into storage slots from right to left"
            // 32  | 32  | 64  | 128 bits


            // Set s_a = 11
            // 111 ... 111 | 000 ... 000
            //             | 128 bits

            let mask_a := not(sub(shl(128, 1), 1))
            v := and(v, mask_a) // clear out the 128 bits
            v := or(v, 11) // set the 128bits to store `11`


            // Set s_b = 22
            // 111 ... 111 | 000 ... 000 | 111 ... 111
            //             | 64 bits     | 128 bits

            let mask_b := not(shl(128, sub(shl(64, 1), 1))) // 0xffffffffffffffff0000000000000000ffffffffffffffffffffffffffffffff
            v := add(v, mask_b)
            // v := or(v, 22) // This will store `22` in the first 128 bits which is s_a 
            v := or(v, shl(128, 22))


            // Set s_c = 33
            // 111 ... 111| 000 ... 000 | 111 ... 111 
            //            | 32 bits     | 192 bits

            let mask_c := not(shl(192, sub(shl(32, 1), 1)))
            v := add(v, mask_c)
            v := or(v, shl(192, 33))

            // Set s_d = 44
            // 000 ... 000 | 111 ... 111 
            // 32 bits     | 224 bits

            let mask_d := not(shl(224, sub(shl(32, 1), 1)))
            v := add(v, mask_d)
            v := or(v, shl(224, 44))

            sstore(0, v)
        }
    } 

    function test_slot_0_offset() public pure returns (uint256 a_offset, uint256 b_offset, uint256 c_offset, uint256 d_offset) {
        // a_offset 0 = 0 * 8 = 0 bits
        // b_offset 16 = 16 * 8 = 128 bits // means that state variable `b` will start after 128 bits
        // c_offset 24 = 24 * 8 = 192 bits
        // d_offset 28 = 28 * 8 = 256 bits
        
        assembly {
            a_offset := s_a.offset
            b_offset := s_b.offset
            c_offset := s_c.offset
            d_offset := s_d.offset
        }
    }

    function test_sstore_using_offset() public {
        assembly {
            // .slot
            // .offset
            let v := sload(s_a.slot)

            // s_d | s_c | s_b | s_a => "EVM packs variables into storage slots from right to left"
            // 32  | 32  | 64  | 128 bits


            // Set s_a = 11
            // 111 ... 111 | 000 ... 000
            //             | 128 bits

            let mask_a := not(sub(shl(mul(s_a.offset, 8), 1), 1))
            v := and(v, mask_a) // clear out the 128 bits
            v := or(v, 11) // set the 128bits to store `11`


            // Set s_b = 22
            // 111 ... 111 | 000 ... 000 | 111 ... 111
            //             | 64 bits     | 128 bits

            let mask_b := not(shl(mul(s_b.offset, 8), sub(shl(64, 1), 1)))
            v := add(v, mask_b)
            // v := or(v, 22) // This will store `22` in the first 128 bits which is s_a 
            v := or(v, shl(mul(s_b.offset, 8), 22))


            // Set s_c = 33
            // 111 ... 111| 000 ... 000 | 111 ... 111 
            //            | 32 bits     | 192 bits

            let mask_c := not(shl(mul(s_c.offset, 8), sub(shl(32, 1), 1)))
            v := add(v, mask_c)
            v := or(v, shl(mul(s_c.offset, 8), 33))

            // Set s_d = 44
            // 000 ... 000 | 111 ... 111 
            // 32 bits     | 224 bits

            let mask_d := not(shl(mul(s_d.offset, 8), sub(shl(32, 1), 1)))
            v := add(v, mask_d)
            v := or(v, shl(mul(s_d.offset, 8), 44))
            
            sstore(0, v)
        }
    } 

}