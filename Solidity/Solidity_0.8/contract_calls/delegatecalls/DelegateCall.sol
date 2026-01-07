// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;
/*
A calls B, sends 100 wei
        B calls C, sends 50 wei
A ---> B ---> C
            msg.sender = B
            msg.value = 50
            execute code on C' state variables
            use ETH in C
====THAT WAS REGULAR CALL=====


A calls B, sends 100 wei
       B delegatecall C
A ---> B ---> C
            msg.sender = A -> because in B msg.sender is A
            msg.value = 100
            execute code on B's state variables
            use ETH in B

- How delegatecall Works
    Let’s break it down in steps:
        Calling contract: You have a contract (let's call it ContractA) that wants to delegate some work.

        Called contract: You have another contract (let's call it ContractB) that holds the code you want to delegate to.

        When you use delegatecall from ContractA to ContractB, ContractA’s storage (state variables) will be used, but the code from ContractB is executed.
*/

contract TestDelegateCall {
    // These State Variables remain unchanged
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) external payable {
        num = 3 * _num;
        sender = msg.sender;
        value = msg.value;
    }
}


// So here i cannot change the code that is already deployed but i can change the TestDelegateCall functionality which will change this computations
contract DelegateCall {
    // The idea is since this is delegating the State Variables here will be updated instead of the contract that i delegate to
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _test, uint _num) external payable {
        // _test.delegatecall(abi.encodeWithSignature("setVars(uint256)", num));

        // The idea is that with this approach i can not write string, but both syntaxes achieves the same thing
        (bool success, bytes memory data) = _test.delegatecall(abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num));

        require(success, "delegatecall failed");
    }
}