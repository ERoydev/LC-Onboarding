// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Wallet} from "../src/Authentication_&_Send/Wallet.sol";

// Examples of deal and hoax
// deal(address, uint) - Set balance of address
// hoax(address, uint) - deal + prank, Sets up a prank and set balance


contract WalletTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet{value: 1e18}();
    }

    function _send(uint256 amount) private {
        (bool ok, ) = address(wallet).call{value: amount}("");
        require(ok, "send ETH failed");
    }

    function testEthBalance() public {
        console.log("ETH balance", address(this).balance / 1e18);
    }

    function testSendEth() public {
        uint bal = address(wallet).balance;

        // deal(address, uint) - Set a balance of address
        deal(address(1), 100); // So i set balance to this address
        assertEq(address(1).balance, 100);

        deal(address(1), 10);
        assertEq(address(1).balance, 10);

        // hoax(address, uint) - deal + prank, Sets up a prank and set balance
        deal(address(1), 123);
        vm.prank(address(1));
        _send(123);
        // I used deal + vm.prank() to achieve that to send ethers to the contract recieve() functions, but i can use hoax for this

        // This is the same as above
        hoax(address(1), 456); // This just combinates `vm.deal(address(1), 456)` and `vm.prank(address(1))`
        _send(456);

        assertEq(address(wallet).balance, bal + 123 + 456);

    }
}