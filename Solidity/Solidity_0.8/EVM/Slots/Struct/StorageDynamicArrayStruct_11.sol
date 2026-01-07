// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


contract EVMStorageDynamicArrayStruct {

    struct Point {
        uint256 x; // slot 0
        uint128 y; // slot 1
        uint128 z; // slot 1
    }

    // slot of element = keccak256(slot where array is declared) + index of element
    // keccak256(slot where array is declared) + size of element * index of element
    
    // keccak256(0) + index of element
    Point[] private arr; // [ Point, Point, Point ]

    constructor() {
        arr.push(Point(11, 22, 33));
        arr.push(Point(44, 55, 66));
        arr.push(Point(77, 88, 99));
    }

    function test_struct_arr(uint256 i) public view returns (uint256 x, uint128 y, uint128 z, uint256 len) {

        // slot of element = keccak256(0) + size of element * index of element
        // size of the element is `2` => each struct will take up two slots to store (x, y, z)
        bytes32 start = keccak256(abi.encode(uint256(0)));

        assembly {
            len := sload(0)
            // x
            // z | y
            
            x := sload(add(start, mul(2, i)))

            let zy := sload(add(start, add(mul(2, i), 1))) // So the right 16bytes will be the value `y` and the other 16bytes will be the value `z`
            y := zy // because when this uint256(zy) is casted to uint128, the left side of 16 bytes will be cutted off and the right side will be putted here
            z := shr(128, zy)
    
        }
    } 
}