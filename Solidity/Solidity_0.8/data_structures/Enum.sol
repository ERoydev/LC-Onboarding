// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract Enum {
    enum Status {
        None, // First Item is the defaul value of this enum
        Pending,
        Shipped,
        Completed,
        Rejected
    }

    Status public status;

    struct Order {
        address buyer;
        Status status;
    }

    Order[] public orders;

    function get() external view returns (Status) {
        return status;
    }

    function set(Status _status) external {
        status = _status;
    }

    function ship() external {
        status = Status.Shipped;
    }
    
    function completed() external {
        status = Status.Completed;
    }

    function rejected() external {
        status = Status.Rejected;
    }

    function reset() external {
        delete status; 
    }
}