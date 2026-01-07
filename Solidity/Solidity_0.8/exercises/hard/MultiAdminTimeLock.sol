
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// CHATGPT GENERATED TASK MY SOLUTION INSPIRED FROM TimeLock exercise


contract MultiAdminTimeLock {
    mapping(address => bool) public admins;
    uint private adminCount;

    mapping(bytes32 => bool) public queued;
    mapping(bytes32 => uint) public approved;
    mapping(bytes32 => mapping(address => bool)) public txApprovedList;

    error NotAllowed();
    error TransactionAlreadyQueued(bytes32 txId);
    error TimestampNotInRangeError(uint timestamp, uint blockTimestamp);
    error TransactionNotQueued(bytes32 txId);
    error TransactionAlreadyApproved(bytes32 txId);
    error TransactionNotApproved(bytes32 txId);
    error AdminCannotApproveTwice(address admin, bytes32 txId);

    event TransactionQueued(
        bytes32 indexed txId,
        uint _value,
        string _func,
        bytes32 _data,
        uint _timestamp
    );

    event TransactionApproved(bytes32 indexed txId, address indexed admin);

    event TransactionExecuted(bytes32 txId);
    event TransactionCanceled(bytes32 txId);

    uint public constant MIN_DELAY = 10;
    uint public constant MAX_DELAY = 1000;

    modifier OnlyAdmin() {
        if (!admins[msg.sender]) {
            revert NotAllowed();
        }
        _;
    }

    constructor(address[] memory _admins) {
        uint length = _admins.length;
        require(length > 0, "Must provide at least one admin");
        adminCount = length;

        for(uint i; i < length; i++) {
            address admin = _admins[i];
            require(admin != address(0), "admin address cannot be zero");
            admins[admin] = true;
        }
    }

    function proposeTransactionQueue(
        address _target,
        uint _value,
        string memory _func,
        bytes32 _data,
        uint _timestamp
    ) external {
        bytes32 txId = getTransactionId(_target, _value, _func, _data, _timestamp);

        if (queued[txId]) {
            revert TransactionAlreadyQueued(txId);
        }

        if (_timestamp < block.timestamp + MIN_DELAY || _timestamp > block.timestamp + MAX_DELAY) {
            revert TimestampNotInRangeError(_timestamp, block.timestamp);
        }

        queued[txId] = true;
        emit TransactionQueued(
            txId,
            _value,
            _func,
            _data,
            _timestamp
        );
    }

    function approveTx(bytes32 txId) external {
        if (!queued[txId]) {
            revert TransactionNotQueued(txId);
        }

        if (txApprovedList[txId][msg.sender]) {
            revert AdminCannotApproveTwice(msg.sender, txId);
        }

        uint threshold = getConsensusThreshold();

        if (approved[txId] >= threshold) {
            revert TransactionAlreadyApproved(txId);
        }

        approved[txId] += 1;
        txApprovedList[txId][msg.sender] = true;
        emit TransactionApproved(txId, msg.sender);
    }

    function executeTx(
            address _target,
            uint _value,
            bytes memory _func,
            bytes32 _data,
            uint _timestamp
        ) external {
            bytes32 txId = getTransactionId(_target, _value, _func, _data, _timestamp);
            uint threshold = getConsensusThreshold();

            if (approved[txId] < threshold) {
                revert TransactionNotApproved(txId);
            }

            if (_timestamp < MIN_DELAY || _timestamp > MAX_DELAY) {
                revert TimestampNotInRangeError(_timestamp, block.timestamp);
            }

            if (_data != bytes32(0)) {
                bytes memory newFuncData = abi.encodePacked(_func, _data); // append data
                (bool success, bytes memory result) = _target.call(newFuncData);
                require(success, "Tranasaction execution failed");
            } else {
                (bool success, bytes memory result) = _target.call(_func);
                require(success, "Tranasaction execution failed");
            }

    }


    function cancelTx(bytes32 txId) external {
        if (!queued[txId]) {
            revert TransactionNotQueued(txId);
        }
        queued[txId] = false;
        emit TransactionCanceled(txId);
    }


    function getConsensusThreshold() public view returns (uint result) {
        result = adminCount - adminCount / 3;
    }

    function getTransactionId(
        address _target,
        uint _value,
        bytes memory _func,
        bytes32 _data,
        uint _timestamp
    ) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _target,
                _value,
                _func,
                _data,
                _timestamp
            )
        );
    }
}


// Test MultiAdminTimeLock
// I will queue a transaction that call setValue(123) for example on this contract
contract TargetContract {
    uint public value;

    function setValue(uint _value) external {
        value = _value;
    }

    function getValue() external view returns (uint) {
        return value;
    }
}

contract Helper {
    function setValueBytes(uint _value) public pure returns (bytes memory) {
        return abi.encodeWithSelector(TargetContract.setValue.selector, _value);
    }

    function getValueBytes() public pure returns (bytes memory) {
        return abi.encodeWithSelector(TargetContract.getValue.selector);
    }
}