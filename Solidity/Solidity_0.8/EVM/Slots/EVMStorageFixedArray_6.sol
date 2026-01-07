// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMStorageFixedArray {
    // Fixed array with elements <= 32 bytes
    // slot of element = slot where array is declared + index of array element

    // slot 0, slot 1, slot 2
    uint256[3] private arr_0 = [1, 2, 3]; // Poneje elementite sa 256 bit-a realno vseki element si zaema edin slot
    
    // slot 3, slot 4, slot 5
    uint256[3] private arr_1 = [4, 5, 6];

    // slot 6 -> (7, 8), slot 7 -> (9, 19), slot 8
    uint128[5] private arr_2 = [7, 8, 9, 10, 11]; // tuk elementite sa 128 bit-a, taka che edin slot moje da bude zaet ot dva elementa


    function test_arr_0(uint256 i) public view returns (uint256 v) {
        assembly {
            v := sload(i) // i
        }
    }

    function test_arr_1(uint256 i) public view returns (uint256 v) {
        assembly {
            // so i say add() meaning start from slot 3 in this case and i is the index so i take slot 3 if `i` is 0 or slot 4 if `i` is 1 and so on
            v := sload(add(3, i)) // 3 + i 
        }
    }

    function test_arr_2(uint256 i) public view returns (uint128 v) {
        assembly {
            let b32 := sload(add(6, div(i, 2))) // 6 + i % 2
            // slot 6, 6, 7,  7,  8
            //     [7, 8, 9, 10, 11];
            //      0, 1, 2,  3,  4

            // slot 6 = 1st element | 0th element
            // slot 7 = 3rd element | 2nd element
            // slot 8 = 000 ... 000 | 4th element

            // if i is even => get right 128 bits => cast to uint128
            // if is odd    => get left 128 bits  => shift right 128 bits

            switch mod(i, 2)
            case 1 { v := shr(128, b32)} // If its 1 (remainder) that means i have an odd number (7, 8) -> 8
            default { v := b32} // if its 0 (remainder) i have even number
        }
    }
}