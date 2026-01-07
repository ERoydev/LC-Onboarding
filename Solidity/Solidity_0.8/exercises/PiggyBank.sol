// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract PiggyBank {   
    bool public contractActive = true;
    address public owner = msg.sender;
    event Deposit(uint amount);
    event Withdraw(uint amount);


    modifier OnlyWhenContractIsActive() {
        require(contractActive, "Piggy bank is not active");
        _;
    }

    modifier OnlyOwner() {  
        require(msg.sender == owner, "Only owner can do this.");
        _;
    }

    receive() external payable OnlyWhenContractIsActive {
        emit Deposit(msg.value);
    } // So the contract recieves ether with this functionality

    function deactivateContract() internal OnlyOwner {
        contractActive = false;
    }

    function withdraw() external OnlyWhenContractIsActive OnlyOwner { 
        emit Withdraw(address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
        deactivateContract();
    }
}