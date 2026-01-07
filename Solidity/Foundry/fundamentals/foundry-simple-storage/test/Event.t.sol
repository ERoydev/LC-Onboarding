// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Solidity 0.8 lecture

import "forge-std/Test.sol";
import "../src/Event/Event.sol"; // Import the Counter contract;


contract EventTest is Test {
    Event public e;

    event Transfer(address indexed from, address indexed to, uint256 amount); // Declare the same event as defined in the Contract

    function setUp() public {
        e = new Event();
    }

    function testEmitTransferEvent() public {
        // function expectEmit(
        //      bool checkTopic1, -> check first indexed parameter
        //      bool checkTopic2, -> check second indexed parameter
        //      bool checkTopic3, - check third indexed parameter
        //      bool checkData -> check the non-indexed data
        // ) external;

        // 1. Tell Foundry which data to check
        // Check index 1, index 2 and data
        vm.expectEmit(true, true, false, true); // set expectation for the next call that emits an event
        // It will check if the params of event emitted by my contract match the expected values specified here

        // 2. Emit the expected event
        emit Transfer(address(this), address(123), 456); // This is the expected event that foundry will compare against the event emmitted by the contract.

        // 3. Call the function that should emit the event
        e.transfer(address(this), address(123), 456);
    }

    function testEmitManyTransferEvent() public {
        address[] memory to = new address[](2);

        uint256[] memory amounts = new uint256[](2);

        for(uint i; i < to.length; i++) {
            // 1.
            // 2.
            vm.expectEmit(true, true, false, true);
            emit Transfer(address(this), address(to[i]), amounts[i]);
        }

        // 3.
        e.transferMany(address(this), to, amounts);
    }


    //  function transferMany(
    //     address from,
    //     address[] calldata to,
    //     uint256[] calldata amounts
    // ) external {
    //     for (uint256 i = 0; i < to.length; i++) {
    //         emit Transfer(from, to[i], amounts[i]);
    //     }
    // }
}