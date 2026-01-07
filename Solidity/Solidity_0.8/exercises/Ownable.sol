// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// state variables
// global variables
// function modifier
// function 
// error handling

contract Ownable {
    address public owner;

    error MyError(address sender, address owner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transferOwnership(address newOwner) external isOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function OnlyOwnerCanCallThisFunc() external isOwner {
        // code
    }

    function anyOneCanCall() external {
        // code
    }

} 