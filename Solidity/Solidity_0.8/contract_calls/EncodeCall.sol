// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


interface IERC20 {
    function transfer(address, uint) external;
}

contract Token {
    function transfer(address, uint) external {}
}

// There are 3 ways to encode a function into bytes to be passed to a contract

contract AbiEncode {
    function test(address _contract, bytes calldata data) external {
        (bool ok, ) = _contract.call(data);
        require(ok, "call failed");
    }

    function encodeWithSignature(address to, uint amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function encodeWithSelector(address to, uint amount) external pure returns (bytes memory) {
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount); // Here i can pass wrong arguments and it will still compiles, allow mistakes
    }

    // Thats the third way of encoding data in a way that if mistake happens it will not compile
    function encodeCall(address to, uint amount) external pure returns (bytes memory) {
        return abi.encodeCall(IERC20.transfer, (to, amount)); // It will not compile if i pass wrong parameters
    }
}