// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);
    event AddedOwner(address indexed owner);

    struct TransactionData {
        address recipient;
        bytes data;
        uint256 amount;
        uint numApprovals;
        bool executed;
    }

    address[] private owners;
    mapping(address => bool) private isOwner;
    uint public required;

    TransactionData[] private transactions;
    mapping(uint => mapping(address => bool)) private approvals; // txId => {address: bool} 

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= owners.length, "Invalid required number of owners");
        
        for (uint i; i < _owners.length; i ++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique");

            isOwner[owner] = true;
            owners.push(owner); 
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    modifier OnlyOwner() {
        require(isOwner[msg.sender], "Only owner is allowed to do this");
        _;
    }

    modifier OnlyNotApprovedOwner(uint id) {
        require(!approvals[id][msg.sender], "Owner have already approved that transcation");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "Transaction with this index does not exists.");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    function addAddressToOwners(address _newOwner) external OnlyOwner {
        require(isOwner[_newOwner] == false, "This address is already an owner");
        owners.push(_newOwner);
        isOwner[_newOwner] = true;

        emit AddedOwner(_newOwner);
    }

    function submit(address _recipient, uint256 _amount, bytes calldata _data) external {
        transactions.push(TransactionData({
            recipient: _recipient,
            data: _data,
            amount: _amount,
            numApprovals: 0,
            executed: false
            
        }));

        emit Submit(transactions.length - 1);
    }

    function approveTransaction(uint txId) external OnlyOwner OnlyNotApprovedOwner(txId) txExists(txId) notExecuted(txId) {
        approvals[txId][msg.sender] = true;
        transactions[txId].numApprovals += 1;

        emit Approve(msg.sender, txId);
    }

    function executeTransaction(uint txId) external OnlyOwner {
        TransactionData storage transaction = transactions[txId];
        require(transaction.numApprovals >= required, "Transaction is not approved by required number of owners");
        transaction.executed = true;

        (bool success, ) = transaction.recipient.call{value: transaction.amount}(transaction.data);
        require(success, "tx failed");

        // payable(transaction.recipient).transfer(amountInWei);
        emit Execute(txId);
    }

    function revoke(uint _txId) external OnlyOwner notExecuted(_txId) txExists(_txId) {
        require(approvals[_txId][msg.sender], "tx not approved");
        approvals[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    function checkAddressIfOwner(address _pk) public view returns (bool) {
        return isOwner[_pk];
    }
}