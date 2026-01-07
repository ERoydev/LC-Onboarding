// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


// CHATGPT Generated exercise


contract VotingSystem {
    address public admin;
    Proposal[] public proposals;
    mapping(address => bool) public addressHasVoted;
    event Voted(address indexed voter, uint proposalIndex);

    constructor() {
        admin = msg.sender;
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "Only admin can interact with this function");
        _;
    }

    modifier AddressNotVotedYet {
        require(addressHasVoted[msg.sender] == false, "You have already voted");
        _;
    }

    modifier NotOwnerOfProposal(uint proposalIdx) {
        require(msg.sender != proposals[proposalIdx].owner, "You cannot vote on proposal you have created");
        _;
    }

    modifier ShouldHaveProposal {
        require(proposals.length > 0, "No proposal to vote on");
        _;
    }

    function changeAdming(address newAdmin) external OnlyAdmin {
        admin = newAdmin;
    }

    struct Proposal {
        address owner;
        string name;
        uint voteCount;
        uint deadline;
    }

    function createDeadline (uint timestamp) external pure returns (uint) {
        return timestamp + 60 * 60;
    }

    function createProposal(string memory _name) external OnlyAdmin {
        uint deadline = this.createDeadline(block.timestamp);
        Proposal memory newProposal = Proposal(msg.sender, _name, 0, deadline);
        proposals.push(newProposal);
    }

    function voteOnProposal(uint proposalIdx) external AddressNotVotedYet NotOwnerOfProposal(proposalIdx) {
        Proposal storage proposal = proposals[proposalIdx];

        proposal.voteCount += 1;
        addressHasVoted[msg.sender] = true;

        emit Voted(msg.sender, proposalIdx);
    }

    function getProposals() external view returns ( Proposal[] memory) {
        return proposals;
    }

    function getWinningProposal() external view ShouldHaveProposal returns (string memory, uint) {
        Proposal memory maxVotedProposal;

        for (uint i = 0; i < proposals.length -1; i ++) {
            if (proposals[i].voteCount > maxVotedProposal.voteCount) {
                maxVotedProposal = proposals[i];
            }
        }

        return (maxVotedProposal.name, maxVotedProposal.voteCount);
    }

    function getProposal(uint index) external view returns (Proposal memory) {
        require(proposals.length > index, "Proposal with this index does not exists.");
        return proposals[index];
    }
}