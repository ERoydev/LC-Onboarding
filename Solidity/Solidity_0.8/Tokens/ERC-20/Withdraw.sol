// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "https://github.com/rari-capital/solmate/src/tokens/ERC20.sol";


/*
    - WETH stands for Wrapped ETH 

WETH wraps ETH into ERC20

- When you deposit ETH a ERC20 token is minted and when you withdraw ETH a ERC20 token is burnt

Idea:
    - Instead of writing two separate contracts one for ETH and one for ERC20 Tokens.
Solution:
    - I can write single contract targeting the erc20 token.
*/

contract WETH is ERC20 {
    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);
    
    // Initialize the Parent Contract (name, symbol, decimals)
    constructor() ERC20("Wrapped Ether", "WETH", 18) {

    }

    fallback() external payable {
        // When the fallback is triggered i need to execute the `.deposit()`
        deposit();
    }

    receive() external payable { }

    function deposit() public payable {
        // User send ETH and the contract will min a erc20 token
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) external {
        // This will burn the erc20 token and send the ETH back
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}