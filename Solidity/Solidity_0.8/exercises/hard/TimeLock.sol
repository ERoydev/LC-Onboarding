// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


// Contract commonly used in DeFi or Daos
// Used to delay a transaction so it gives the user some time to react before the transaction is submitted
contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);
    error TransactionIsNotQueued(bytes32 txId);
    error TimestampNotPassedError(uint blockTimestamp, uint timestamp);
    error TimestampExpiredError(uint blockTimestamp, uint expiresAt);
    error TxFailedError();
    error NotQueuedError(bytes32 txId);

    event Cancel(
        bytes32 txId
    );

    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );

    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );

    uint public constant MIN_DELAY = 10;
    uint public constant MAX_DELAY = 1000;
    uint public constant GRACE_PERIOD = 1000;

    address public owner;
    mapping(bytes32 => bool) public queued;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable { }

    modifier OnlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    // Encode and hash these values to derive the transaction Id
    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint timestamp
    ) public pure returns (bytes32 txId) {
        return keccak256(
            abi.encode(
                _target, 
                _value, 
                _func, 
                _data, 
                timestamp
            )
        );
    }

    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external OnlyOwner { // Delay logic here
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);

        if (queued[txId]) {
            revert AlreadyQueuedError(txId);
        }

        if (
            _timestamp < block.timestamp + MIN_DELAY || 
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }

        queued[txId] = true;
        emit Queue(txId, _target, _value, _func, _data, _timestamp );
    }

    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable OnlyOwner returns (bytes memory) { // After delay time has passed
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);

        if (!queued[txId]) {
            revert TransactionIsNotQueued(txId);
        }

        if (block.timestamp < _timestamp) {
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }

        if (block.timestamp > _timestamp + GRACE_PERIOD) {
            revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
        }

        queued[txId] = false;
        
        bytes memory data;
        if (bytes(_func).length > 0) {
            data = abi.encodePacked(
                bytes4(keccak256(bytes(_func))), _data
            );
        } else {
            data = _data;
        }

        // execute the tx
        (bool ok, bytes memory res) = _target.call{value: _value}(data);

        if (!ok) {
            revert TxFailedError();
        }

        emit Execute(txId, _target, _value, _func, _data, _timestamp);

        return res;
    }

    function cancel(bytes32 _txId) external OnlyOwner {
        if (!queued[_txId]) {
            revert NotQueuedError(_txId);
        }

        queued[_txId] = false;
        emit Cancel(_txId);
    }

}

contract TestTimeLock {
    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function test() external view {
        require(msg.sender == timeLock);
        // more code here such as
        // - upgrade contract
        // - transfer funds
        // - switch price oracle
    }

    function getTimestamp() external view returns (uint) {
        return block.timestamp + 100;
    }
}