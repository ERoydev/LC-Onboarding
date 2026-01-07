// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Solidity 0.8 lecture

import "forge-std/Test.sol";
import "../src/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld public helloWorld; // Deployed contract instance, a variable that points to the deployed smart contract

    function setUp() public {
        helloWorld = new HelloWorld();
    }

    function testGreet() public view {
        assertEq(helloWorld.greet(), "Hello, World!");
    }
}
