// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract MultiDelegatecall {
    error DelegatecallFailed();

    // So here in data i pass already encoded data from my Helper contract where i encode it with selector
    function multiDelegatecall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);

        for(uint i; i < data.length; i ++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            results[i] = res;
        }
    }
}

/*
    Why we use multi delegatecall?
        - The idea is that i could use Multicall instead of delegatecall, but ...
        - When i use multicall i will have
        - alice -> multi call --- call ---> test (msg.sender = multi call) => here msg.sender will be equal to multicall address not the msg.sender address
*/

contract TestMultiDelegatecall is MultiDelegatecall {
    event Log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint) {
        emit Log(msg.sender, "func2", 2);
        return 111;
    }
}

// I just use this to get encoded bytecode for my functions using selector instead of strings
contract Helper {
    function getFuncData1(uint x, uint y) external pure returns (bytes memory) {
        // abi.encodeWithSignature("func1(x, y)", x, y); 
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
    }

    function getFuncData2() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }
}