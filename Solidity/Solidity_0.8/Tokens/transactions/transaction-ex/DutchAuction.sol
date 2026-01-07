// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// I have used from solidity by example ERC721 token to use this Auction contract where i deploy it seperately to mint and approve the nft!

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract DutchAuction {
    event Bid(address, uint);

    uint private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable owner;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    bool public closeAuction;

    constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nft, // This is the address of the deployed NFT contract and this makes the connection to the NFT contract for my inteface
        uint _nftId
    ) {
        owner = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require(_startingPrice >= _discountRate * DURATION, "Starting price < discount");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    modifier NotOwner() {
        require(msg.sender != owner, "owner not allowed to do this");
        _;
    }

    modifier NotClosed() {
        require(!closeAuction, "auction is closed");
        _;
    }

    function getPrice() public view returns (uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable NotClosed {
        require(block.timestamp < expiresAt, "auction expired");
        uint price = getPrice();
        require(msg.value >= price, "ETH < price"); // check if sender have sended correct amount of ether to buy

        nft.transferFrom(owner, msg.sender, nftId);

        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        closeAuction = true;
    }

}