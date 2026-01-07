// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
Fallback executed when
- function doesn't exist
- directly send ETH

fallback() or receive()?

    Ether is sent to contract
               |
        is msg.data empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
       /        \
    receive()   fallback()
*/

// receive() -> When Ether is sent with no data - Can get ether - does not accept data
// fallback() -> When unknown function is called or called with data - Can get ether - Does accept data

contract Fallback {
    event Log(string func, address sender, uint value, bytes data);

    // When i try to call a function that does not exist it will trigger the fallback() function
    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }
    // receive is executed when the data that is send is empty

    // Summary: Fallback is executed when i call function that does not exist or msg.data is not empty
    // While receive will be called when msg.data is empty
}