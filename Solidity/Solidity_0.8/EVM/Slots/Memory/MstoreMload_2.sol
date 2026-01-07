// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


// For example i know that `0x40` is where Solidity keep free memory pointer
// so `mload(0x40) gives me current free memory location

contract EVMMemBasic {
    // mstore(p, v) => store 32 bytes to memory starting at memory location p
    // mload(p) => load 32 bytes from memory starting at memory location p 

    function test_1() public pure returns(bytes32 b32) {
        assembly {
            let p := mload(0x40)
            mstore(p, 0xababab)
            b32 := mload(p)
        }
    }

    function test_2() public pure {
        assembly {
            mstore(0, 0x11)
            //    0 1 2 3 -> Memory location 0 index will be the first two hexadecimal number and so on till 3
            // 0x0000000000000000000000000000000000000000000000000000000000000011
            mstore(1, 0x22)
            //    0 1
            // 0x00(start offset from here)00000000000000000000000000000000000000000000000000000000000000
            // 0x2200000000000000000000000000000000000000000000000000000000000000
            mstore(2, 0x33)
            //    0 1 2
            // 0x0000000000000000000000000000000000000000000000000000000000000000
            // 0x0033000000000000000000000000000000000000000000000000000000000000
            mstore(3, 0x44)
            // 0x0000440000000000000000000000000000000000000000000000000000000000

        }
    }

    // mstore(offset, value) writes 32 bytes starting at `offset`
    // - If value is small (like 0x22), it's right-aligned: goes into the LAST byte of the 32-byte chunk
    // - The other 31 bytes are padded with zeros to the left
    // - So mstore(1, 0x22) writes from byte 1 to 32, and byte 32 will be 0x22 -> Check example `mstore(1, 0x22)`
    // WARNING: If offset is not a multiple of 32, it may overwrite overlapping memory


}