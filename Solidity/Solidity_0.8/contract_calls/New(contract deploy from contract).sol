// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract Account {
    address public bank;
    address public owner;

    constructor(address _owner) payable {
        bank = msg.sender;
        owner = _owner;
    }
}

contract AccountFactory {
    Account[] public accounts; // Holds the addresses of where the new account contract is deployed

    function createAccount(address _owner) external payable {
        // In this {} braces i need to specify the amount of ether that we are gonna be sending, because Account is payable in constructor
        Account account = new Account{value: 111}(_owner); // Thats how i deploy a contract from another contract
        accounts.push(account);
    }

}