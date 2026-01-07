// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Solidity 0.8 lecture

import "forge-std/Test.sol";
import "../src/ConsoleLog/Counter.sol"; // Import the Counter contract

contract CounterTest is Test {
    Counter public counter; // Deployed contract instance, a variable that points to the deployed smart contract

    function setUp() public {
        counter = new Counter();
    }

    function testGet() public view {
        assertEq(counter.get(), 0);
    }

    function testInc() public {
        counter.inc();
        assertEq(counter.get(), 1);
    }

    function test_RevertWhenDecUnderflow() public {
        vm.expectRevert(stdError.arithmeticError); // Expect an arithmetic error due to underflow
        counter.dec(); // This will revert because `count` starts at 0
    }

    function testDecUndeflow() public {
        vm.expectRevert(stdError.arithmeticError);
        counter.dec();
    }

    function testDec() public {
        counter.inc();
        counter.inc();
        counter.inc();

        counter.dec();
        assertEq(counter.get(), 2);
    }
}
