// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract FunctionSelector {
    // This is the first 4 bytes of the Function selector example of how it works
    function getSelector(string calldata _func) external pure returns (bytes4) {
        // From the function i hash it and take the first 4 bytes
        return bytes4(keccak256(bytes(_func)));
    }
}

contract Receiver {
    event Log(bytes data);

    function transfer(address _to, uint _amount) external {
        emit Log(msg.data);

        // This data encodes the function to call and the parameters to pass to the function

        // 0xa9059cbb -> first 4bytes encodes the function to call (transfer) its so called Function Selector
        // The rest of the data encodes the parameters to pass to the function 
        // 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc 
        // 40000000000000000000000000000000000000000000000000000000000000014 
    }


}