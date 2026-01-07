// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;
contract Constructor {
    address public owner;
    uint public x;

    // The constructor is only called once when we deploy the contract
    // Used to initialize my State Variables
    // Cannot be called again after contract is deployed
    constructor(uint _x) {
        owner = msg.sender;
        x = _x;
    }
}