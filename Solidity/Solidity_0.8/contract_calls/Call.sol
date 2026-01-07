// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// send calls to other contracts 
// call method to send ether to any address has become the recommended way

contract TestCall {
    string public message;
    uint public x;

    event Log(string message);

    fallback() external payable {
        emit Log("fallback was called");
    }

    receive() external payable { 
        emit Log("receive was called");
    }

    function foo(string memory _message, uint _x) external payable returns (bool, uint) {
        message = _message;
        x = _x;
        return (true, 999);
    }
}   

contract Call {
    bytes public data;

    function callFoo(address _test) external payable { //_test is my contract address 
        // When i `.call()` i need to specify the amount of gas i am going to send and amount of ether i am going to send
        (bool success, bytes memory _data) = _test.call{value: 111}(abi.encodeWithSignature("foo(string,uint256)", "call foo", 123));

        require(success, "call failed");
        data = _data;
    }

    function callDoesNotExist(address _test ) external {
        (bool success, ) = _test.call(abi.encodeWithSignature("doesNotExist();"));

        require(success, "call failed");
    }
}