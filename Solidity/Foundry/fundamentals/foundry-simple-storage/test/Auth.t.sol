// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Wallet} from "../src/Authentication_&_Send/Wallet.sol";

contract AuthTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet();
    }

    function testSetOwner() public {
        wallet.setOwner(address(1));
        assertEq(wallet.owner(), address(1));
    }

    // Test should Revert(fail)
    function test_RevertIfNotOwner() public {
        vm.expectRevert(); // Expect the transaction to revert
        vm.prank(address(1)); // Simulate address(1) as the caller for the next call msg.sender = address(1)
        wallet.setOwner(address(1)); // This should revert because address(1) is not the owner
    }

    function test_RevertSetOwnerAgain() public {
        // msg.sender = address(this)
        wallet.setOwner(address(1));
        // wallet owner will be address(1) now

        vm.startPrank(address(1)); // Instead of writing vm.prank multiple times i just start it here and i set it for all next calls

        // msg sender = address(1)
        // vm.prank(address(1));
        wallet.setOwner(address(1));
        // vm.prank(address(1));
        wallet.setOwner(address(1));
        // ...
        wallet.setOwner(address(1));

        vm.stopPrank(); // To stop this prank behaviour

        // msg.sender = address(this)
        vm.expectRevert(); // Next call will revert
        wallet.setOwner(address(1));
    }
}