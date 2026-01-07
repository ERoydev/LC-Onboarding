// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    // I want to make clear that this contract to be able to receive ether
    // if someone calls a function that doesn't exists inside this contract, then we want that transaction to fail
    receive() external payable {}

    function withdraw(uint _amount) external {
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount); // Replace owner State Variable with msg.sender this save a little gas
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}