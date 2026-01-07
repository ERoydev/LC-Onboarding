// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
Library allows me to reuse code in other contracts.
*/


library Math {
    // They have several restrictions;
    //  - I cannot declare State variables inside here.
    function max(uint x, uint y) internal pure returns (uint) { // Since i will use library functions inside another contract it should be internal or public if i deploy it seperately
        return x >= y ? x : y;
    }
}

contract Test {
    function testMax(uint x, uint y) external pure returns (uint) {
        return Math.max(x, y);
    }
}


library ArrayLib {
    function find(uint[] storage arr, uint x) internal view returns (uint) {
        for(uint i = 0; i < arr.length; i ++) {
            if (arr[i] == x) {
                return i;
            }
        }

        revert("not found");
        // Revert is used to abort a function and undo all state changes that were made beofre the revert was triggered.
    }
}

contract TestArray {
    uint[] public arr = [3, 2, 1];

    function testFind() external view returns (uint i) {
        return ArrayLib.find(arr, 2);
    }
}

contract TestArray2 {
    using ArrayLib for uint[]; // This tells solidity that for this data type `uint[]` attach all the functionalities defined in ArrayLib
    uint[] public arr = [3, 2, 1];

    function testFind() external view returns (uint i) {
        return arr.find(2); // Now i can use this type of invoking 
    }
}