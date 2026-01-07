// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage; // Deployed contract instance, a variable that points to the deployed smart contract

    function setUp() public {
        // This function is run before each test function
        // It is used to set up the state of the contract before each test
        // You can use it to deploy a new instance of the contract or set up any other state you need for your tests
        simpleStorage = new SimpleStorage();
    }

    function testRetrieve() public view {
        assertEq(simpleStorage.retrieve(), 0);
    }
}
