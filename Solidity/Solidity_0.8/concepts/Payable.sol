// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
In Solidity, when you want a contract or a function to be able to receive Ether, you must mark it with the keyword payable.

1. Payable Functions

function deposit() external payable {
    // Anyone can send Ether to this function
}
✅ It allows the function to receive Ether.

💰 The Ether is automatically stored in the contract’s balance.

2. Payable Addresses

address payable public owner;

This allows the address to receive Ether or be used with .transfer() or .send().

Regular address types can’t receive Ether directly. You must convert them to payable.

*/

contract Payable {
    address payable public owner; // By declaring an address as payable this address is now able to send `ether`

    constructor() {
        owner = payable(msg.sender);
    }

    function deposit() external payable {

    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}