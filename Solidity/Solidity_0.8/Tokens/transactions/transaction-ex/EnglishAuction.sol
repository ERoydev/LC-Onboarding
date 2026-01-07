// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
Remember:
    - MyNFT contract represents my NFT (address of this contract is my nft)
    - While the nftId represents the minted NFT token from this contract  
*/

// 1. Deploy NFT contract and mint NFT to some wallet address with some nftId
// 2. Deploy the Auction contract
// 3. In the NFT contract APPROVE the Auction contract(address) that this contract can spend this nft !!!
// 4. Then i can buy and do stuff because i have allowed this Auction Contract to deal with this NFT

interface IERC721 { // lets say my NFT is an computer but i sell it in form of NFT token so who owns token owns computer
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed sender, uint amount);

    uint private constant TIMEOUT = 2 minutes;

    IERC721 public immutable nft;
    uint public immutable nftId;
    address payable public immutable owner;

    uint public lastBidTime;

    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;
    bool public ended;

    bool public closeAuction;

    constructor(
        address _nft, // address of the type nft i am going to sell
        uint _nftId // nftId of this nft that i am selling from thins nft
    ) {
        owner = payable(msg.sender);

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    modifier NotClosed() {
        require(!closeAuction, "auction is closed");
        _;
    }

    function getPrice() public view returns (uint) {
        return highestBid;
    }

    function bid() public payable {
        require(!closeAuction, "auction is closed");
        require(msg.value > highestBid, "bid must be greater than current highest bid!");
        // require(highestBidder != address(0), "Higher bidder is 0");

        lastBidTime = block.timestamp;
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
        emit Withdraw(msg.sender, bal);
    }
    
    function end() external {
        require(!closeAuction, "auction is already finished");
        require(block.timestamp >= lastBidTime + TIMEOUT, "timeout is not finished");
        require(!ended, "ended");
        require(highestBidder != address(0), "highessBidder is addres zero");
        closeAuction = true;
        ended = true;

        if (block.timestamp - lastBidTime > 5) {
            nft.transferFrom(address(this), highestBidder, nftId);
            owner.transfer(highestBid);
        } else {
            nft.transferFrom(address(this), owner, nftId);
        }
    }
}