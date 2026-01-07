import { AuctionDetails } from "../../../intefaces/AuctionDetails";
import { formatUnixTimestamp } from "../../../utils/formatUnixTimestamp";


export default function AuctionCard({
    auction,
    handleAuctionClick,
}: {
    auction: AuctionDetails,
    handleAuctionClick: (auction: AuctionDetails) => void;
}) {

    const ClickAuctionHandler = () => {
        handleAuctionClick(auction);
    }

    return(
        <div
            onClick={() => ClickAuctionHandler()}
            key={auction.auctionId}
            className="hover:cursor-pointer rounded-lg shadow-md bg-white overflow-hidden hover:shadow-xl hover:scale-105 transition-transform duration-300"
            >

            <img
            src={auction.imageurl}
            alt={auction.nftName}
            className="w-full h-48 object-cover"
            />

            <div className="p-4">
                <h2 className="text-lg font-semibold text-gray-800">
                    {auction.nftName}
                </h2>
                <p className="text-sm text-gray-600 mt-2">
                    Current Bid: <span className="font-bold">{auction.highestBid} ETH</span>
                </p>
                <p className="text-sm text-gray-600 mt-2">
                    Ends On: {formatUnixTimestamp(auction.endTime)}
                </p>
            </div>
        </div>
    );
}