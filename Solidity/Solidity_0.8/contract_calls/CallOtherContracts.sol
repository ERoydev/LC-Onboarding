// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract CallTestContract {
    function setX(address _test, uint _x) external {
        // First way of calling other contracts is to initialize them
        // _test is the address of the TestContract
        TestContract(_test).setX(_x);
    }

    function setX1(TestContract _test, uint _x) external {
        // Other way is to specify them in the parameter
        _test.setX(_x);
    }

    function getX(address _test) external view returns (uint) {
        return TestContract(_test).getX();
    }

    function setXandSendEther(address _test, uint _x) external payable {
        TestContract(_test).setXandReceiveEther{value: msg.value}(_x); // pass msg.value
    }

    // Named output here (uint x, uint value)
    function getXandValue(address _test) external returns (uint x, uint value) {
        (x, value) = TestContract(_test).getXandValue();
    }
}

contract TestContract{
    uint public x;
    uint public value = 123;

    function setX(uint _x) external {
        x = _x;
    }

    function getX() external view returns (uint) {
        return x;
    }

    function setXandReceiveEther(uint _x) external payable {
        x = _x;
        value = msg.value;
    }

    function getXandValue() external payable returns (uint, uint) {
        return (x, value);
    }
}