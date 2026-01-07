// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract TestMultiCall {
    function func1() external view returns (uint, uint) {
        return (1, block.timestamp);
    }

    function func2() external view returns (uint, uint) {
        return (2, block.timestamp);
    }

    function getData1() external pure returns (bytes memory) {
        // abi.encodeWithSignature("func1()") -> This is the same but instead of writing string i use selector bellow
        return abi.encodeWithSelector(this.func1.selector); // returns the bytes for this function -> func1() and i can use them to pass in staticcall() to execute
    }
    
    function getData2() external pure returns (bytes memory) {
        // abi.encodeWithSignature("func1()") -> This is the same but instead of writing string i use selector bellow
        return abi.encodeWithSelector(this.func2.selector);
    }
}

// https://medium.com/coinmonks/call-staticcall-and-delegatecall-1f0e1853340


/*
- staticcall()
    executes code from another contract, but in a read-only mode.
    Cannot modify any state — neither in the caller nor the target.
    Used to safely read data from other contracts.
    msg.sender and context stay as the caller’s, but any write attempts will revert.
 */


// This is how i aggregate multiple queries into a single function call
contract MultiCall {
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "target length != data length");

        bytes[] memory results = new bytes[](data.length);

        for(uint i; i < targets.length; i ++) {

            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "call failed");

            results[i] = result;
        }

        return results;
    }
}
