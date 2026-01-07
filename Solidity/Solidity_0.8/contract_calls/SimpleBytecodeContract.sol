// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// Contract that will deploy this Creation code
contract Factory {
    event Log(address addr);

    function deploy() external {
        bytes memory bytecode = hex"6960ff60005260206000f3600052600a6016f3"; // 38 length of the string when i divide it by two i get the sice of the bytecode
        address addr;
        assembly {
            // create(0 -> amount of ether to send)
            // add bytecode means skip 32 bytes `0x20` == 32 add(bytecode, 0x20)
            // then 
            addr := create(0, add(bytecode, 0x20), 0x13) // 0x13 == 19
        }
        require(addr != address(0), "deploy failed");

        emit Log(addr);
    }
}

interface IContract {
    function getMeaningOfLife() external view returns (uint);
}

// Runtime code
// Creation code
// Factory contract

// https://www.evm.codes/playground
/*
Run time code - return 255
60ff60005260206000f3

// Store 255 to memory
mstore(p, v) - store v at memory p to p + 32

PUSH1 0xff
PUSH1 0
MSTORE

// Return 32 bytes from memory
return(p, s) - end execution and return data from memory p to p + s

PUSH1 0x20
PUSH1 0
RETURN

Creation code - return runtime code
6960ff60005260206000f3600052600a6016f3

// Store run time code to memory
PUSH10 0X60ff60005260206000f3
PUSH1 0
MSTORE

// Return 10 bytes from memory starting at offset 22
PUSH1 0x0a
PUSH1 0x16
RETURN
*/