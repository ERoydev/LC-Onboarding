import { getBrowserProvider, getAuctionWriteContract, auctionReadContract } from "../utils/contract";
import { approveNFT } from "./nftContractService";
import { ethers, parseEther } from "ethers";
import { logger } from "../utils/logger";
import { extractRevertMessageFromError } from "../utils/extractRevertMessageFromError";


export async function createAuction(data: any) {
    await approveNFT(data.tokenId);

    const contractWithSigner = await getAuctionWriteContract();
    const _nftAddress = import.meta.env.VITE_NFT_CONTRACT_ADDRESS;

    // Convert ETH string to WEI
    const priceInWei = parseEther(data.startingPrice.toString());

    try {
        const tx = await contractWithSigner.createAuction(_nftAddress, data.tokenId, priceInWei, data.duration);
        await tx.wait();
        logger.log("Auction created successfully:", tx);
        return {};
    } catch (error) {
        logger.error("Error creating auction:", error);
        
        const errorResult = extractRevertMessageFromError(error);
        return errorResult;
    }
}

export async function fetchActiveAuctions() {
    try {
        const provider = getBrowserProvider();
        const currentBlock = await provider.getBlockNumber();

        // Fetch all "AuctionStarted" events
        const events = await auctionReadContract.queryFilter("AuctionStarted", 0, currentBlock);

        const now = Math.floor(Date.now() / 1000); // Current timestamp in seconds

        // Fetch the latest state of each auction
        const activeAuctions = await Promise.all(
            events.map(async (event: any) => {
                const { auctionId } = event.args;

                // Query the latest state of the auction from the contract
                const auctionData = await auctionReadContract.getAuction(auctionId);

                return {
                    seller: auctionData.seller,
                    auctionId: Number(auctionId),
                    startPrice: ethers.formatEther(auctionData.startPrice),
                    endTime: Number(auctionData.endTime),
                    highestBid: ethers.formatEther(auctionData.highestBid),
                    highestBidder: auctionData.highestBidder,
                    nftTokenId: auctionData.nftTokenId,
                    imageurl: "", // Placeholder for image URL
                    nftName: "", // Placeholder for NFT name
                };
            })
        );

        // Filter only active auctions
        return activeAuctions.filter((auction) => auction.endTime > now);
    } catch (error) {
        logger.error("Error fetching auctions:", error);
        return [];
    }
}

export async function fetchNonActiveAuctions() {
    try {
        const now = Math.floor(Date.now() / 1000); // Current timestamp in seconds

        // Fetch the total number of auctions from the contract
        const maxAuctionId = Number(await auctionReadContract.auctionId());

        // Fetch the latest state of each auction
        const nonActiveAuctions = await Promise.all(
            Array.from({ length: maxAuctionId + 1}, (_, index) => index).map(async (auctionId) => {
                // Query the latest state of the auction from the contract
                const auctionData = await auctionReadContract.getAuction(auctionId);

                // Only include auctions where endTime has passed
                if (Number(auctionData.endTime) <= now) {
                    return {
                        seller: auctionData.seller,
                        auctionId: Number(auctionId),
                        startPrice: ethers.formatEther(auctionData.startPrice),
                        endTime: Number(auctionData.endTime),
                        highestBid: ethers.formatEther(auctionData.highestBid),
                        highestBidder: auctionData.highestBidder,
                        auctionEnded: auctionData.auctionEnded, // Fetch auctionEnded status
                        nftTokenId: auctionData.nftTokenId,
                        imageurl: "", // Placeholder for image URL
                        nftName: "", // Placeholder for NFT name
                    };
                }
                return null; // Exclude auctions where endTime has not passed
            })
        );

        // Filter out null values (auctions that haven't ended yet)
        return nonActiveAuctions.filter((auction) => auction !== null);
    } catch (error) {
        logger.error("Error fetching non-active auctions:", error);
        return [];
    }
}


export async function fetchUserBidHistory(userAddress: string) {
    try {
        // Create a filter for the NewBid event
        const filter = auctionReadContract.filters.NewBid(userAddress, null); // Filter by bidder (userAddress)

        // Query the events using the filter
        const events = await auctionReadContract.queryFilter(filter, 0, "latest");

        // Map and process events
        const userBids = await Promise.all(
            events.map(async (event: any) => {
                const block = await event.getBlock(); // Fetch block details for the timestamp
                return {
                    auctionId: Number(event.args.auctionId),
                    bidAmount: ethers.formatEther(event.args.amount), // Decode the amount
                    transactionHash: event.transactionHash, // Include transaction hash for reference
                    timestamp: new Date(block.timestamp * 1000).toLocaleString(), // Convert to readable date
                };
            })
        );
        return userBids;
    } catch (error) {
        logger.error("Error fetching user bid history:", error);
        return [];
    }
}

export async function placeBidAuction(auctionId: number, bidAmount: string) {
    try {
        const contractWithSigner = await getAuctionWriteContract();
        // Convert ETH string to WEI
        const bidAmountInWei = parseEther(bidAmount);
        const tx = await contractWithSigner.placeBid(auctionId, { value: bidAmountInWei });
        await tx.wait();
        logger.log("Bid placed successfully:", tx);
        return {};
    } catch (error) {
        logger.error("Error placing bid:", error);
        const errorResult = extractRevertMessageFromError(error);
        return errorResult;
    }
}

export async function endAuction(auctionId: number) {
    try {
        const contractWithSigner = await getAuctionWriteContract();

        const tx = await contractWithSigner.endAuction(auctionId);
        await tx.wait();
        logger.log("Auction ended successfully:", tx);
        return {}
    } catch (error) {
        logger.error("Error ending auction:", error);
        const errorResult = extractRevertMessageFromError(error);
        return errorResult;
    }
}

// TODO: Refactor this function it is very ugly, separate the logic in different functions
export async function getLockedAuctionFunds(account: string) {
    try {
        // TODO: Implement the logic to fetch ended Auctions so users can withdraw their funds based on this
        // User and Sellers need to have withdraw in their profile
        const provider = getBrowserProvider();
        const currentBlock = await provider.getBlockNumber();

        // Fetch all "AuctionStarted" events
        const events = await auctionReadContract.queryFilter("AuctionEnded", 0, currentBlock);
        
        const auctionIds = events.map((event: any) => Number(event.args.auctionId));
        // TODO: I can use `auctionIds` to fetch from the server database where i will store them
        
        // Bellow is the wrong approach for this implementation
        const auctionData = await Promise.all(
            auctionIds.map(async (auctionId: number) => {
                const auction = await auctionReadContract.getAuction(auctionId);
                const isWithdrawn = await auctionReadContract.isWithdrawedByOwner(auctionId);

                return {
                    auctionId: auctionId,
                    highestBidder: auction.highestBidder,
                    highestBid: ethers.formatEther(auction.highestBid),
                    auctionEnded: auction.auctionEnded,
                    endTime: Number(auction.endTime),
                    seller: auction.seller,
                    nftTokenId: auction.nftTokenId,
                    isWithdrawn: isWithdrawn,
                    imageurl: "", // Placeholder for image URL
                    nftName: "", // Placeholder for NFT name
                };
            })
        );

        // Filter only auctions where the user is the seller so he needs to withdraw his won funds
        const sellerAuctions = auctionData.filter((auction) => 
            auction.seller.toLowerCase() === account.toLowerCase() && 
            auction.highestBidder.toLowerCase() !== ethers.ZeroAddress &&
            !auction.isWithdrawn
        );
        // Filter if already withdrawn

        let depositedFunds = 0;
        let auctionDepositedIds = [];
        // Filter deposited funds of unwon auctions
        for (let i = 0; i < auctionIds.length; i++) {
            const auctionId = auctionIds[i];
            const result = await auctionReadContract.deposits(auctionId, account);
            if (result > 0) {
                auctionDepositedIds.push(auctionId);
            }
            depositedFunds += Number(result);
        }

        return {
            soldAuctions: sellerAuctions,
            depositedFunds: depositedFunds,
            auctionDepositedIds: auctionDepositedIds
        }

    } catch (error) {
        logger.error("Error fetching locked auction funds:", error);
        const errorResult = extractRevertMessageFromError(error);
        return errorResult;
    }
}

export async function withdrawDepositedFunds(auctionId: number) {
    try {
        const contractWithSigner = await getAuctionWriteContract();
        const tx = await contractWithSigner.withdraw(auctionId);
        await tx.wait();
        logger.log("Profits withdrawn successfully:", tx);
        return {};
    } catch (error) {
        logger.error("Error withdrawing profits:", error);
        const errorResult = extractRevertMessageFromError(error);
        return errorResult;
    }
}

export async function withdrawAuctionProfit(auctionId: number) {
    try {
        const contractWithSigner = await getAuctionWriteContract();
        const tx = await contractWithSigner.withdrawFunds(auctionId);
        await tx.wait();
        logger.log("Auction profit withdrawn successfully:", tx);
        return {};
    } catch (error) {
        logger.error("Error withdrawing auction profit:", error);
        const errorResult = extractRevertMessageFromError(error);
        return errorResult;
    }
}