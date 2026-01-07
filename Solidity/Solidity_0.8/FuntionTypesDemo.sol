// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FunctionTypesDemo {
    
    // Public State Variable (auto-creates a getter)
    uint public publicNumber = 100;

    // Private State Variable
    uint private secretNumber = 42;

    // Immutable address set in constructor
    address public immutable owner;

    // Constructor (special function)
    constructor() {
        owner = msg.sender;
    }

    // External function - only callable from outside
    function setPublicNumber(uint _newNumber) external {
        publicNumber = _newNumber;
    }

    // Internal function - only used inside this contract or inherited ones
    function _double(uint _value) internal pure returns (uint) {
        return _value * 2;
    }

    // Private function - only used within this contract
    function _getSecretNumber() private view returns (uint) {
        return secretNumber;
    }

    // Public view function - reads state, doesn't modify
    function readOwner() public view returns (address) {
        return owner;
    }

    // Public pure function - no state access
    function multiply(uint a, uint b) public pure returns (uint) {
        return a * b;
    }

    // Public function that uses internal & private functions
    function getSecretDouble() public view returns (uint) {
        uint secret = _getSecretNumber();  // private
        return _double(secret);            // internal
    }

    // Payable function - accepts ETH
    function sendEth() public payable {}

    // Read how much ETH this contract holds
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Receive function - gets triggered on raw ETH transfer
    receive() external payable {}

    // Fallback - catches unknown calls or wrong function selectors
    fallback() external payable {}
}
