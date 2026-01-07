// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
    `virtual` => keyword to specify that this function can be inherited and customized by the child contract

    `override` => keyword that allows overriding the inherited implementation of a function.
*/

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
    
    function bar() public pure virtual returns (string memory) {
        return "A";
    }

    function baz() public pure returns (string memory) {
        return "A";
    }
}


contract B is A {
    function foo() public pure override returns (string memory) {
        return "B";
    }
    
    // I allow this function to be overritten in a contract that inherits this contract
    function bar() public pure virtual override returns (string memory) {
        return "B";
    }

    // Here i will still have the baz() function from contract A
}

contract C is B {
    function bar() public pure override returns (string memory) {
        return "C";
    }
}