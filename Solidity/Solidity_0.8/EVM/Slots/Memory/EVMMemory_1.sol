// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


// RULE: 0x20 is 32 bytes because `0x20` in hex is `32` in decimal

// Often all operations when read and write from memory happen in chunks of 32 bytes
// Memory is arranged in chunks of 32 bytes

// Solidity assigns three special regions of the memory for special purposes

// 0x00 First 64 bytes is the `Scratch space`
//  - This is reserved for temporary usage by the EVM and Solidity compiler.
//  - You should not rely on the data here to persist.

// 0x40 The next 32 bytes stores the `Free memory pointer`
//  - This holds a pointer to the next available "free" space in memory.
//  - It’s used by the Solidity compiler to know where to start writing new data.

// 0x60 The next 32 bytes is the `Zero slot`
//  - This is a memory region always initialized to zero (0x00).

// 0x80 The next 32 bytes is where the free memory starts `Initial free memory`
//  - This is where your actual contract data starts getting written if you use memory in functions.
//  - If you ask Solidity to new an array or return data from a function, it will write starting from here.


// Store data into memory is `mstore(p, v)` -> p(location of memory to start writing the data), v(data to store 32 bytes)
// mstore(0, 0xff) -> 000000...00000ff
