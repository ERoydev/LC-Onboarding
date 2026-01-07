// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


contract HashFunc {
    function hash(string memory text, uint num, address addr) external pure returns (bytes32){
        // I need to encode these inputs. into bytes
        return keccak256(abi.encodePacked(text, num, addr)); // Return a bytes hash of all these parameters
    }

    // abi.encode -> encodes data into bytes
    // abi.encodePacked -> still encodes data into bytes but compresses it

    // Just encode data into bytes 
    function encode(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encode(text0, text1);
    }

    // Compresses this data 
    function encodePacked(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encodePacked(text0, text1);
    }
    
    // The problem is that encodePacked can create hash collisions
    // Example: first input: "AAAA", "BBB", produce the same output like "AAA", "ABBB"
    function collision(string memory text0, string memory text1) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text0, text1));
        // If i use abi.encode() problem will be fixed!
    }

}