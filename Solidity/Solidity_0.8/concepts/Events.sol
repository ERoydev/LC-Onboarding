// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


contract Event {
    event Log(string message, uint val);
    event IndexedLog(address indexed sender, uint val);
    
    // `indexed` used when declaring event parameters => allows efficient filtering of logs from the blockchain.
    // sender is indexed, so i can filter logs based on the sender's address

    // NOTE: Solidity allows maximum of 3 indexed parameters in an event. Anything beyond must be non-indexed
    
    function example() external {
        emit Log("Good message", 24);
        emit IndexedLog(msg.sender, 789);
    }

    event Message(address indexed _from, address indexed _to, string message);

    function sendMessage(address _to, string calldata message) external {
        emit Message(msg.sender, _to, message);
    }
}