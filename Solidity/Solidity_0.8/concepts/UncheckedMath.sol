// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract UncheckedMath {
    function add (uint x, uint y) external pure returns (uint) {
        unchecked {
            return x + y;

        }   
    }

    /*
    unchecked math:
        It adds x and y without checking for overflow or underflow.
        The unchecked block disables Solidity’s default overflow protection (introduced in Solidity ^0.8.0).

    unchecked math if it goes bellow 0 => Wraps around to 0 (no error)
        Meaning the default approach is checked math which checks for overflow and underflow and that is why consumes more gas because of the checks
    */

    function sub(uint x, uint y) external pure returns (uint) {
        unchecked { // lower gas 
            return x - y; // Disale the overflow error, if y > x it will result in negative number, SAVES GAS
        }
    }
}