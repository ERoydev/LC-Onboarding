// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Solidity 0.8 lecture

import "forge-std/Test.sol";
import "../src/Time/Time.sol"; // Import the Counter contract;


contract TimeTest is Test {
    Auction public auction;
    uint public startAt;

    // vm.warp - set block.timestamp to future timestamp
    // vm.roll - set block.number
    // skip - increment current timestamp
    // rewind - decrement current timestamp

    function setUp() public {
        auction = new Auction();
        startAt = block.timestamp;
    }

    function test_RevertBidFailsBeforeStartTime() public {
        vm.expectRevert(bytes("cannot bid"));

        auction.bid();
    }

    function testBid() public {
        vm.warp(startAt + 1 days);
        auction.bid();
    }

    function test_RevertBidFailsAfterEndTime() public {
        vm.expectRevert(bytes("cannot bid"));
        vm.warp(startAt + 2 days);
        auction.bid();
    }

    function testEnd() public {
        vm.warp(startAt + 2 days);
        auction.end();
    }

    function test_RevertEndFailsBeforeEndTime() public {
        vm.expectRevert(bytes("cannot end"));
        vm.warp(startAt + 1 days + 23 hours + 59 minutes);
        auction.end();
    }

    function testTimestamp() public {
        uint t = block.timestamp;
        
        // skip - increment current timestamp
        skip(100);
        assertEq(block.timestamp, t + 100);
        // rewind - decrement current timestamp
        rewind(10);
        assertEq(block.timestamp, t + 100 - 10);
    }

    function testBlockNumber() public {
        // vm.roll - set block.number
        uint b = block.number;
        vm.roll(999);

        assertEq(block.number, 999);
    }
}   