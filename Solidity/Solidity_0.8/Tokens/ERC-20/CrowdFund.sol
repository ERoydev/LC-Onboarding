// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
cancel, -> owner
pledge, -> users sends token to this campaign
unpledge, -> users while campaingh is still going
claim, -> creator claims
refund -> users can refund

*/

import "./IERC20.sol";

contract CrowdFund {
    event Launch(address indexed owner, uint count, uint goal, uint32 startAt, uint32 endAt);
    event Pledge(address indexed user, uint indexed id, uint amount);
    event Unpledge(address indexed user, uint indexed id, uint amount);
    event Cancel(uint id);
    event Claim(address indexed owner, uint amount, uint id);
    event Refund(uint _id, address indexed sender, uint amount);


    struct Campaign {
        address owner;
        uint256 startAt;
        uint256 endAt;
        uint256 goal;
        uint pledged;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAdmount; // Campaing -> user -> pledgedAmmount

    constructor(address _token) {
        token = IERC20(_token); // Here i pass the actual token address contract of ERC20 wrapped in IERC20 Interface!
    }

    function launch(
        uint _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "endAt < startAt");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        count += 1;
        campaigns[count] = Campaign({
            owner: msg.sender,
            startAt: _startAt,
            endAt: _endAt,
            goal: _goal,
            pledged: 0,
            claimed: false
        });

        emit Launch(msg.sender, count, _goal, _startAt, _endAt);
    }   

    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "not creator");
        require(block.timestamp < campaign.startAt, "not started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        require(_amount >= 0, "amount < 0");

        Campaign storage campaign = campaigns[_id];
        require(campaign.startAt <= block.timestamp, "startAt > now");
        require(campaign.endAt > block.timestamp, "endAt < now");

        campaign.pledged += _amount;    
        pledgedAdmount[_id][msg.sender] = _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(msg.sender, _amount, _id);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.startAt <= block.timestamp, "startAt > now");
        require(campaign.endAt > block.timestamp, "endAt < now");

        campaign.pledged -= _amount;
        pledgedAdmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(msg.sender, _amount, _id);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.owner == msg.sender, "sender != owner");
        require(campaign.endAt <= block.timestamp, "endAt > now");
        require(!campaign.claimed, "claimed");
        require(campaign.pledged > 0, "pledged = 0");
        require(campaign.goal <= campaign.pledged, "goal is not reached");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);

        emit Claim(msg.sender, campaign.pledged, _id);
    }
    
    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged < goal");

        uint bal = pledgedAdmount[_id][msg.sender];
        pledgedAdmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }

}