// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


contract BitwiseOps {
    // x     = 1110 = 8 + 4 + 2 + 0 = 14
    // y     = 1011 = 8 + 0 + 2 + 1 = 11
    // x & y = 1010 = 8 + 0 + 2 + 0 = 10 ( The idea is that 1, 1 = true, 1, 0 = false, 1, 1 = true, 0, 1 = false, because and operator requires both statements to be true
    function add(uint x, uint y) external pure returns (uint) {
        return x & y;
    }

    // x     = 1100 = 8 + 4 + 0 + 0 = 12
    // y     = 1001 = 8 + 0 + 0 + 1 = 9
    // x | y = 1101 = 8 + 4 + 0 + 1 = 13
    function or(uint x, uint y) external pure returns (uint) {
        return x | y;
    }

    // x     = 1100 = 8 + 4 + 0 + 0 = 12
    // y     = 0101 = 0 + 4 + 0 + 1 = 5
    // x ^ y = 1001 = 8 + 0 + 0 + 1 = 9 (The idea is that one bit should be true ONLY if two of them are true(1) we return false(0))
    function xor(uint x, uint y) external pure returns (uint) {
        return x ^ y;
    }
    
    // x  = 00001100 =   0 +  0 +  0 +  0 + 8 + 4 + 0 + 0 = 12
    // ~x = 11110011 = 128 + 64 + 32 + 16 + 0 + 0 + 2 + 1 = 243
    function not(uint8 x) external pure returns (uint8) {
        return ~x;
    }

    // 1 << 0 = 0001 --> 0001 = 1
    // 1 << 1 = 0001 --> 0010 = 2
    // 1 << 2 = 0001 --> 0100 = 4
    // 1 << 3 = 0001 --> 1000 = 8
    // 3 << 2 = 0011 --> 1100 = 12 -> Shift all bits with the specified step in this case step is `2`
    function shiftLeft(uint256 x, uint256 bits)
        external
        pure
        returns (uint256)
    {
        return x << bits;
    }

    // 8  >> 0 = 1000 --> 1000 = 8
    // 8  >> 1 = 1000 --> 0100 = 4
    // 8  >> 2 = 1000 --> 0010 = 2
    // 8  >> 3 = 1000 --> 0001 = 1
    // 8  >> 4 = 1000 --> 0000 = 0
    // 12 >> 1 = 1100 --> 0110 = 6
    function shiftRight(uint256 x, uint256 bits)
        external
        pure
        returns (uint256)
    {
        return x >> bits;
    }

    // Exercise
    // Get last n bits from x
    // x = 1101, n = 3 => output = 0101
    function getLastNBits(uint x, uint n) external pure returns (uint) {

        // So i shift 1 n times it looks lik this if n is 3 i will have 1 -> 1000 and when i have -1, (1 << n) - 1 = 0111
        uint mask = (1 << n) - 1;

        // Example, last 3 bits
        // x        = 1101 = 13
        // mask     = 0111 = 7
        // x & mask = 0101 = 5
        return x & mask;

    }

    // Get last n bits from x using mod operator
    function getLastNBitsUsingMod(uint256 x, uint256 n)
        external
        pure
        returns (uint256)
    {
        // 1 << n = 2 ** n
        return x % (1 << n);
    }
}