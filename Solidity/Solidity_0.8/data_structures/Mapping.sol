// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


contract Mapping {
    mapping(address => uint) public balances; // I create key-value pair where i specify that key is address and value is uint
    mapping(address => mapping(address => bool)) public isFriend; // key is address value is key-value pair with (address = bool)
    // {0x23123: {0x123123: true}, 0x12312312: {...}, ...}

    function examples() external {
        balances[msg.sender] = 123;
        uint bal = balances[msg.sender];
        uint bal2 = balances[address(1)]; 

        balances[msg.sender] = 456;
        balances[msg.sender] += 456; // 123 + 456 = 579

        delete balances[msg.sender]; // 0

        isFriend[msg.sender][address(this)] = true; // address(this) this is tha address of the current contract
    }
}