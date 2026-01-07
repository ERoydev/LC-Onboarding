// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// visibility
// private - only inside contracts that define it
// internal - only inside contract and child contracts
// public - inside and outisde contract
// external - only from outside contract

contract VisibilityBase {
    uint private x = 0;
    uint internal y = 1;
    uint public z = 2;

    function privateFunc() private pure returns (uint) {
        return 0;
    }

    function internalFunc() internal pure returns (uint) {
        return 100;
    }

    function publicFunc() public pure returns (uint) {
        return 200;
    }

    function externalFunc() external pure returns (uint) {
        return 300;
    }

    function examples() external view {
        x + y + z;
        
        privateFunc();
        internalFunc();
        publicFunc();

        this.externalFunc(); // This is a cheat to call external functions internally (this -> calling into this contract) => This Approach is very gas inefficient so dont do it at all.
    }

}

contract VisibilityChild is VisibilityBase {
    function examples2() external view {
        y + z;
        internalFunc();
        publicFunc();
    }

}