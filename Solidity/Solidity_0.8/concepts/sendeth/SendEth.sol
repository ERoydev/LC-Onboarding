// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


// 3 ways to send ETH
// transfer - 2300 gas, reverts
// send - 2300 gas, returns bool
// call - all gas, returns bool and data


/*
For example when i use `.transfer()` the ETH Virtual Machine will attach 2300 gas to the receiving contract
and if the receiving contract does not have enough gas to execute the function it will revert the transaction.
*/

contract SendEther {
    constructor() payable {}

    receive() external payable {}

    function sendViaTransfer(address payable _to) external payable {
        _to.transfer(123); // Transfer to address _to amount of specified ether
    }

    function sendViaSend(address payable _to) external payable {
        bool sent = _to.send(123); 
        require(sent, "send failed");
        // This is not used often, it is used transfer or call
    }

    function sendViaCall(address payable _to) external payable {
        (bool success, ) = _to.call{value: 123}("");
        require(success, "call failed");
    }
}

contract EthReceiver {
    event Log(uint amount, uint gas);

    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}