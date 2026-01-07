// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EnglishAuction.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "forge-std/console.sol";
import {NFT} from "../src/NFT.sol";

// Simple mock NFT contract
contract MockNFT is ERC721 {
    uint256 public tokenId;

    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 _tokenId) external {
        _mint(to, _tokenId);
    }
}

contract EnglishAuctionTest is Test {
    EnglishAuction public auction;
    MockNFT public nft;

    address seller = address(1);
    address bidder1 = address(2);
    address bidder2 = address(3);

    uint256 public nftId = 1;
    uint256 public auctionId;

    
    event AuctionStarted(
        address indexed seller, 
        uint256 indexed auctionId, 
        uint256 startPrice, 
        uint256 endTime,
        uint256 highestBid,
        address highestBidder
    );

    function setUp() public {
        auction = new EnglishAuction();
        nft = new MockNFT();

        //Mint NFT to seller
        vm.startPrank(seller);
        nft.mint(seller, nftId);

        // Seller approves the auction contract
        nft.approve(address(auction), nftId);

        uint256 startPrice = 1 ether;
        uint256 durationInMinutes = 120;

        // Remember that this createAuction transfer the nft from `seller` to the Auction contract
        auctionId = auction.createAuction( // Set the initial auction
            address(nft),
            nftId,
            startPrice,
            durationInMinutes
        );
        // Now address(auction) => is holding the NFT token

        vm.stopPrank();
    }

    function testCreateAuction() public {
        
        vm.startPrank(seller);
        EnglishAuction testingAuction = new EnglishAuction();
        MockNFT testingNft = new MockNFT();
        uint testingNftId = 2;

        testingNft.mint(seller, testingNftId);
        testingNft.approve(address(testingAuction), testingNftId);

        vm.expectEmit(true, true, true, true);
        emit AuctionStarted(seller, auctionId, 1 ether, block.timestamp + 10 * 1 minutes, 1 ether, address(0));
 
        uint256 testAuctionId = testingAuction.createAuction(address(testingNft), testingNftId, 1 ether, 10);

        (
            address auctionSeller,
            IERC721 _nft,
            uint256 nftTokenId,
            uint256 highestBid,
            address highestBidder,
            uint256 startPrice,
            uint256 endTime,
            bool auctionEnded
        ) = testingAuction.auctions(testAuctionId);

        assertEq(auctionSeller, seller);
        assertEq(address(_nft), address(testingNft));
        assertEq(nftTokenId, testingNftId);
        assertEq(highestBid, 1 ether);
        assertEq(highestBidder, address(0));
        assertEq(startPrice, 1 ether);
        assertEq(endTime, block.timestamp + 10 * 1 minutes);
        assertEq(auctionEnded, false);

        vm.stopPrank();
    }

    function testPlaceBid() public {
        vm.startPrank(bidder1);

        (, , , uint256 highestBidPre, address highestBidderPre, , ,) = auction.auctions(auctionId);
        assertNotEq(highestBidPre, 2 ether);
        assertNotEq(highestBidderPre, bidder1);

        vm.deal(bidder1, 2 ether);
        auction.placeBid{value: 2 ether}(auctionId);

        (, , , uint256 highestBid, address highestBidder, , ,) = auction.auctions(auctionId);
        assertEq(highestBid, 2 ether);
        assertEq(highestBidder, bidder1);

        vm.stopPrank();

        vm.startPrank(bidder2);

        vm.deal(bidder2, 2.5 ether);
        auction.placeBid{value: 2.5 ether}(auctionId);

        (, , , uint256 newHighestBid, address newHighestBidder, , ,) = auction.auctions(auctionId);

        assertEq(newHighestBid, 2.5 ether);
        assertEq(newHighestBidder, bidder2);

        vm.stopPrank();
    }

    function testRevertBidLowerThanCurrent() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.deal(bidder2, 1.5 ether);
        vm.prank(bidder2);
        vm.expectRevert("Bid must be higher the the current highest bid");
        auction.placeBid{value: 1.5 ether}(auctionId);
    }

    function testAuctionEndAndTransfer() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);
        assertNotEq(nft.ownerOf(nftId), bidder1);

        assertEq(seller.balance, 0); // Seller is broke
        assertEq(nft.ownerOf(nftId), address(auction)); // But he sell nft

        assertEq(nft.balanceOf(address(auction)), 1);
        vm.warp(block.timestamp + 130 minutes); // fast-forward time
        vm.prank(seller);
        auction.endAuction(auctionId);
        assertEq(nft.balanceOf(address(auction)), 0);

        // Check seller should recieve highestBid
        assertEq(seller.balance, 0); // Seller should withdraw his funds
        assertNotEq(nft.ownerOf(nftId), address(auction));
        assertEq(nft.ownerOf(nftId), bidder1);

        assertEq(auction.deposits(auctionId, address(bidder1)), 0);

        (, , , , , , , bool auctionEnded) = auction.auctions(auctionId);
        assertTrue(auctionEnded);
    }

    function testWithdraw() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.deal(bidder2, 3 ether);
        vm.prank(bidder2);
        auction.placeBid{value: 3 ether}(auctionId);

        vm.warp(block.timestamp + 121 minutes);
        vm.prank(seller);
        auction.endAuction(auctionId);

        uint256 preBalance = bidder1.balance;
        vm.prank(bidder1);
        auction.withdraw(auctionId);
        uint256 postBalance = bidder1.balance;
        
        assertGt(postBalance, preBalance);
    }

    function testWithdrawShouldRevertIfWinnerTriesToWithdraw() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.deal(bidder2, 3 ether);
        vm.prank(bidder2);
        auction.placeBid{value: 3 ether}(auctionId);

        vm.warp(block.timestamp + 121 minutes);
        vm.prank(seller);
        auction.endAuction(auctionId);

        uint256 preBalance = bidder1.balance;
        vm.prank(bidder1);
        auction.withdraw(auctionId);
        uint256 postBalance = bidder1.balance;
        
        assertGt(postBalance, preBalance);

        vm.prank(bidder2);
        vm.expectRevert();
        auction.withdraw(auctionId);
    }

    function testWithdrawShouldRevertIfNotExistingAuctionId() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.deal(bidder2, 2.5 ether);
        vm.prank(bidder2);
        auction.placeBid{value: 2.5 ether}(auctionId);

        vm.warp(block.timestamp + 121 minutes);
        vm.prank(seller);
        auction.endAuction(auctionId);
        
        vm.prank(bidder1);
        vm.expectRevert();
        auction.withdraw(auctionId + 1);
    }

    function testWithdrawFundsShouldRevertWithNonExistingAuctionId() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.warp(block.timestamp + 121 minutes);
        vm.prank(seller);
        auction.endAuction(auctionId);
        
        vm.prank(seller);
        vm.expectRevert();
        auction.withdrawFunds(auctionId + 1);
    }

    function testCannotEndAuctionTwice() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.warp(block.timestamp + 121 minutes);
        vm.prank(seller);
        auction.endAuction(auctionId);

        vm.prank(seller);
        vm.expectRevert("Auction has already ended");
        auction.endAuction(auctionId);
    }

    function testAuctionExtendTime() public {
        // fast-forward to 1 min before end
        vm.warp(block.timestamp + 119 minutes);

        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        (, , , , , , uint256 newEndTime,) = auction.auctions(auctionId);
        assertGt(newEndTime, block.timestamp + 1 minutes); // auction extended
    }

    function testWithdrawFunds() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.deal(bidder2, 2.5 ether);
        vm.prank(bidder2);
        auction.placeBid{value: 2.5 ether}(auctionId);

        vm.warp(block.timestamp + 121 minutes);
        vm.prank(seller);
        auction.endAuction(auctionId);

        assertEq(seller.balance, 0);

        vm.prank(seller);
        auction.withdrawFunds(auctionId);

        assertEq(seller.balance, 2.5 ether);
    }

    function testWithdrawFundsShouldRevertIfNotSeller() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.deal(bidder2, 2.5 ether);
        vm.prank(bidder2);
        auction.placeBid{value: 2.5 ether}(auctionId);

        vm.warp(block.timestamp + 121 minutes);
        vm.prank(seller);
        auction.endAuction(auctionId);

        assertEq(seller.balance, 0);

        vm.prank(bidder1);
        vm.expectRevert();
        auction.withdrawFunds(auctionId);
    }

    function testWithdrawFundsCannotWithdrawIfAuctionIsNotEnded() public {
        vm.deal(bidder1, 2 ether);
        vm.prank(bidder1);
        auction.placeBid{value: 2 ether}(auctionId);

        vm.deal(bidder2, 2.5 ether);
        vm.prank(bidder2);
        auction.placeBid{value: 2.5 ether}(auctionId);

        vm.prank(bidder1);
        vm.expectRevert();
        auction.withdrawFunds(auctionId);
    }
    
}
