import { AuctionDetails } from "./AuctionDetails";
import TokenData from "./TokenData";

export type DisplayableNft = {
    name: string;
    image: string;
    description: string;
    price: string;
    tokenId: number;
    isAuction?: boolean;
    auctiondetails?: AuctionDetails;
    tokenDetails?: TokenData;
  };
  
export function mapToDisplayableNft(nft: TokenData | AuctionDetails): DisplayableNft {
if ("tokenId" in nft) {
    // It's TokenData
    return {
    name: nft.name,
    image: nft.image,
    description: nft.description,
    price: nft.price,
    tokenId: nft.tokenId,
    };
} else {
    // It's AuctionDetails
    return {
    name: nft.nftName,
    image: nft.imageurl,
    description: "Auction NFT",
    price: nft.startPrice,
    tokenId: nft.auctionId,
    auctiondetails: nft,
    };
}
}
  