// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @dev - I use pull-over-push strategy and implemente withdraw functions for all transactions calling ".call()"
contract EnglishAuction is ReentrancyGuard {
    struct Auction {
        address seller;
        IERC721 nft;
        uint256 nftTokenId;
        uint256 highestBid;
        address highestBidder;
        uint256 startPrice;
        uint256 endTime;
        bool auctionEnded;
    }

    string public contractLabel;

    mapping(uint256 => Auction) public auctions; // index => Auction struct
    mapping(uint256 => mapping(address => uint256)) public deposits; // auction index => deposits
    
    mapping(uint256 => uint256) public sold; // auctionId => sold for price
    mapping(uint256 => bool) public isWithdrawedByOwner; // auctionId => bool if owner withdrawed his funds

    uint256 public auctionId;
    uint256 private nextAuctionId;

    uint256 private constant AUCTION_MIN_DURATION = 2; // minutes
    uint256 constant private AUCTION_EXTEND_TIME = 5 minutes; // Bid placed in withit 2 minutes before endTime, extends endTime by 5 min

    event AuctionStarted(
        address indexed seller, 
        uint256 indexed auctionId, 
        uint256 startPrice, 
        uint256 endTime,
        uint256 highestBid,
        address highestBidder
    );

    event AuctionEnded(address indexed winner, uint256 indexed auctionId, uint256 amount);
    event NewBid(address indexed bidder,uint256 indexed auctionId, uint256 amount);
    event AuctionExtendedBy5Minutes(uint256 indexed _tokenId, address indexed seller, uint256 newDuration);
    event Withdraw(address indexed user, uint256 indexed auctionId, uint256 amount);
    event SellerWithdraw(address indexed seller, uint256 indexed auctionId, uint256 amount);

    constructor() {
        contractLabel = "Auction Contract v1";
    }

    function createAuction(
        address _nftAddress,
        uint256 _nftTokenId,
        uint256 _startPrice,
        uint256 _durationInMinutes
    ) external nonReentrant returns (uint256 _auctionId) {

        auctionId = nextAuctionId++;
        Auction storage auction = auctions[auctionId];

        require(IERC721(_nftAddress).getApproved(_nftTokenId) == address(this), "Nft must approve this address as a spender");
        require(_startPrice > 0, "Starting price must be greater than 0");
        require(_durationInMinutes >= AUCTION_MIN_DURATION, "Duration must be longer than or equal to 5 mintues");

        auction.seller = msg.sender;
        auction.nft = IERC721(_nftAddress);
        auction.nftTokenId = _nftTokenId;
        auction.startPrice = _startPrice;
        auction.endTime = block.timestamp + _durationInMinutes * 1 minutes;
        auction.highestBid = _startPrice; // Set initial highest bidd for address(0)

        require(auction.nft.ownerOf(_nftTokenId) == msg.sender, "Caller is not the owner of the NFT");

        emit AuctionStarted(
            auction.seller, 
            auctionId, 
            _startPrice, 
            auction.endTime,
            auction.highestBid,
            auction.highestBidder
        );

        auction.nft.transferFrom(auction.seller, address(this), _nftTokenId);
        return auctionId;
    }

    function placeBid(uint256 _auctionId) external payable {
        require(_auctionId < nextAuctionId, "Auction with this id doesn't exist");
        Auction storage auction = auctions[_auctionId];

        require(!auction.auctionEnded, "Auction is ended by owner");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.value > auction.highestBid, "Bid must be higher the the current highest bid");
        require(msg.sender != auction.highestBidder, "You are already the highest bidder");
        require(msg.sender != auction.seller, "Seller cannot bid to an auction");

        // Extend endTime logic here
        if (auction.endTime - block.timestamp <= 2 minutes) {
            auction.endTime += AUCTION_EXTEND_TIME;
            emit AuctionExtendedBy5Minutes(_auctionId, auction.seller, auction.endTime);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;

        uint moneyToGive = auction.highestBid - deposits[_auctionId][auction.highestBidder]; // If not exist => will return default value == 0
        deposits[_auctionId][auction.highestBidder] += moneyToGive;

        emit NewBid(auction.highestBidder, _auctionId, auction.highestBid);
    }

    function endAuction(uint256 _auctionId) external nonReentrant {
        require(_auctionId < nextAuctionId, "Auction with this id doesn't exist");
        Auction storage auction = auctions[_auctionId];

        require(!auction.auctionEnded, "Auction has already ended");
        require(block.timestamp >= auction.endTime, "Auction is still active");
        require(msg.sender == auction.seller, "Only the seller can end the auction");

        auction.auctionEnded = true;
        emit AuctionEnded(auction.highestBidder, _auctionId, auction.highestBid);

        if (auction.highestBidder == address(0)) {
            // No bidder return nft to seller
            require(sold[_auctionId] == 0, "You cannot take your nft that has active bid");

            auction.nft.transferFrom(address(this), auction.seller, auction.nftTokenId);

        } else if (auction.highestBidder != address(0)) {
            // I can do this on withdraw to reuse deposits => Check if this cause some issues
            deposits[_auctionId][auction.highestBidder] = 0; // clear highest bidder

            // Instead of transfering funds i will hold and make the seller pull them
            sold[_auctionId] = auction.highestBid;

            auction.nft.transferFrom(address(this), auction.highestBidder, auction.nftTokenId);
        } 
    }

    /// @dev - Used by the person who owns the auction to withdraw his money
    function withdrawFunds(uint256 _auctionId) external nonReentrant {
        require(_auctionId < nextAuctionId, "Auction with this id doesn't exist");
        Auction storage auction = auctions[_auctionId];

        require(auction.auctionEnded, "Auction not ended");
        // The most important check is this
        require(msg.sender == auction.seller, "This address cannot withdraw auction that he is not a seller");

        uint amount = sold[_auctionId];
        require(amount > 0, "Amount to withdraw should be greater than 0");
        sold[_auctionId] = 0;
        isWithdrawedByOwner[_auctionId] = true;

        emit SellerWithdraw(msg.sender, _auctionId, amount);    

        (bool sent, ) = payable(msg.sender).call{value: amount}(""); // .call() to work with contacts too 
        require(sent, "Transfer failed");
    }

    /// @dev - Used by users who participated but have not won the auction
    function withdraw(uint256 _auctionId) external nonReentrant {
        require(_auctionId < nextAuctionId, "Auction with this id doesn't exist");
        Auction storage auction = auctions[_auctionId];

        require(auction.auctionEnded, "Auction not ended");
        require(msg.sender != auction.highestBidder, "Auction winner cannot withdraw");

        uint amount = deposits[_auctionId][msg.sender];
        require(amount > 0, "Amount to withdraw should be greater than 0");

        deposits[_auctionId][msg.sender] = 0;

        emit Withdraw(msg.sender, _auctionId, amount);

        (bool sent, ) = payable(msg.sender).call{value: amount}(""); // .call() to work with contacts too 
        require(sent, "Transfer failed");
    }

   function getAuction(uint256 _auctionId) public view returns (
        address seller,
        uint256 startPrice,
        uint256 endTime,
        uint256 highestBid,
        address highestBidder,
        address nft,
        uint256 nftTokenId,
        bool auctionEnded
    ) {
        require(_auctionId < nextAuctionId, "auction with this id does not exists");
        
        Auction storage auction = auctions[_auctionId];
        return (
            auction.seller,
            auction.startPrice,
            auction.endTime,
            auction.highestBid,
            auction.highestBidder,
            address(auction.nft),
            auction.nftTokenId,
            auction.auctionEnded
        );
    }


}