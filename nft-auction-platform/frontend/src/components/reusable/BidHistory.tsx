import Spinner from "./Spinner";


export default function BidHistory({
    loading,
    bidHistory
}: {
    loading: boolean;
    bidHistory: {
        auctionId: string;
        bidAmount: string;
        timestamp: string;
        transactionHash: string;
    }[];
}) {
    return(
         <div className="mt-12 text-center pb-16">
            <h2 className="text-2xl font-bold mb-4">Your Bid History</h2>
            {loading ? (
            <Spinner />
            ) : bidHistory.length > 0 ? (
            <table className="w-full border-collapse border border-gray-300">
                <thead>
                <tr>
                    <th className="border border-gray-300 px-4 py-2">Auction ID</th>
                    <th className="border border-gray-300 px-4 py-2">Bid Amount (ETH)</th>
                    <th className="border border-gray-300 px-4 py-2">Timestamp</th>
                    <th className="border border-gray-300 px-4 py-2">Transaction Hash</th>
                </tr>
                </thead>
                <tbody>
                {bidHistory.map((bid, idx) => (
                    <tr key={idx}>
                    <td className="border border-gray-300 px-4 py-2 text-center">{bid.auctionId}</td>
                    <td className="border border-gray-300 px-4 py-2 text-center">{bid.bidAmount}</td>
                    <td className="border border-gray-300 px-4 py-2 text-center">{bid.timestamp}</td>
                    <td className="border border-gray-300 px-4 py-2 text-center">
                        <a
                        href={`https://etherscan.io/tx/${bid.transactionHash}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-500 hover:underline"
                        >
                        {`${bid.transactionHash.slice(0, 6)}...${bid.transactionHash.slice(-4)}`}
                        </a>
                    </td>
                    </tr>
                ))}
                </tbody>
            </table>
            ) : (
            <p className="text-gray-600">You have not placed any bids yet.</p>
            )}
        </div>
    );
}