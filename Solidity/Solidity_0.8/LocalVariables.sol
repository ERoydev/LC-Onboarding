// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract StateVariables {
    uint public i;
    bool public b;
    address public myAddress;

    function foo() external {
        uint x = 123; // Local Variabes
        bool f = false; // Local Variables
        // After fn executes this variables will be gone, they are cheap to use

        x += 456;
        f = true;

        // This will update these State Variables, the blockchain state of this contract and they are expensive to use
        i = 123;
        b = true;
        myAddress = address(1);
    }
}
