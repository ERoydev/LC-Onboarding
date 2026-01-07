import { DisplayableNft } from "../../../intefaces/DisplayableNft";
import { formatUnixTimestamp } from "../../../utils/formatUnixTimestamp";

export default function DisplayNftModal({
    closeModal,
    selectedNft,
    errorMessage,
    currentAccount,
    isBiddable,
    handleEndAuction,
    BID_VALUE,
    handlePlaceBid,
    handlePurchase,
    payWithETH,
    setPayWithETH,
}: {
    closeModal: () => void;
    selectedNft: DisplayableNft;
    handlePurchase?: () => void;
    errorMessage?: string | null;
    currentAccount?: string;
    isBiddable?: boolean;
    handleEndAuction?: () => void;
    BID_VALUE?: number;
    handlePlaceBid?: () => void;
    payWithETH?: boolean;
    setPayWithETH?: (value: boolean) => void;
}) {

    return (
        <div
            className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
            onClick={closeModal} // Close modal when clicking on the background
        >
            <div
                className="bg-white rounded-lg shadow-lg p-6 w-11/12 max-w-2xl relative"
                onClick={(e) => e.stopPropagation()} // Prevent click event from propagating to the background
            >
                <button
                    onClick={closeModal}
                    className="hover:cursor-pointer scale-125 hover:scale-150 absolute top-4 right-4 text-gray-500 hover:text-gray-800"
                >
                    ✖
                </button>

                <h2 className="text-2xl font-bold mb-4">Name: {selectedNft.name}</h2>

                <img
                    src={selectedNft.image}
                    alt={selectedNft.name}
                    className="w-full h-64 object-cover rounded-lg mb-4"
                />

                {/* Details */}
                <div className="flex flex-col gap">
                    <p className="text-gray-600">
                        <strong className="text-gray-800">Description:</strong> {selectedNft.description}
                    </p>
                    <p className="text-gray-600">
                        <strong className="text-gray-800">Price:</strong>{" "}
                        <span className="text-green-600 font-semibold">{selectedNft.price} USDCx</span>
                    </p>
                    <p className="text-gray-600">
                        <strong className="text-gray-800">Token ID:</strong>{" "}
                        <span className="text-blue-600 font-semibold">{selectedNft.tokenId}</span>
                    </p>
                </div>

                {/* If its an auction */}
                {selectedNft.auctiondetails && (
                    <div className="flex flex-col gap">
                        <p className="text-gray-600">
                            <strong className="text-gray-800">Seller:</strong>{" "}
                            <span className="text-purple-600 font-semibold">{selectedNft.auctiondetails.seller}</span>
                        </p>
                        <p className="text-gray-600">
                            <strong className="text-gray-800">Current Bid:</strong>{" "}
                            <span className="text-green-600 font-semibold">
                                {parseFloat(selectedNft.auctiondetails.highestBid).toFixed(6)} ETH
                            </span>
                        </p>
                        <p className="text-gray-600">
                            <strong className="text-gray-800">Highest Bidder:</strong>{" "}
                            <span className="text-blue-600 font-semibold">
                                {selectedNft.auctiondetails.highestBidder || "No bids yet"}
                            </span>
                        </p>
                        <p className="text-gray-600">
                            <strong className="text-gray-800">Ends On:</strong>{" "}
                            <span className="text-red-600 font-semibold">
                                {formatUnixTimestamp(selectedNft.auctiondetails.endTime)}
                            </span>
                        </p>

                        {selectedNft.auctiondetails.seller.toLocaleLowerCase() === currentAccount && (
                            <div className="mt-4 flex justify-between">
                                <button
                                    onClick={handleEndAuction}
                                    className="hover:cursor-pointer bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition"
                                >
                                    End Auction
                                </button>
                            </div>
                        )}
                        {isBiddable && (
                            <div className="mt-4 flex justify-between">
                                {currentAccount !== selectedNft.auctiondetails.seller.toLocaleLowerCase() && (
                                <button
                                    onClick={handlePlaceBid}
                                    className="hover:cursor-pointer bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition"
                                >
                                    Increment Bid with {BID_VALUE} ETH
                                </button>

                                )}
                            </div>
                        )}

                    </div>
                )}

                {/* If its marketplace */}
                {setPayWithETH && !selectedNft.auctiondetails && (
                    <div>
                        <div className="mb-4">
                            <label className="block text-gray-700 font-semibold mb-2">
                            Pay with ETH:
                            </label>

                            <div className="flex items-center gap-4">
                            <button
                                onClick={() => setPayWithETH(true)}
                                className={`px-4 py-2 rounded-lg hover:cursor-pointer ${
                                payWithETH
                                    ? "bg-green-500 text-white"
                                    : "bg-gray-200 text-gray-700"
                                }`}
                            >
                                Yes
                            </button>
                            <button
                                onClick={() => setPayWithETH(false)}
                                className={`px-4 py-2 rounded-lg hover:cursor-pointer ${
                                !payWithETH
                                    ? "bg-green-500 text-white"
                                    : "bg-gray-200 text-gray-700"
                                }`}
                            >
                                No
                            </button>
                            </div>
                        </div>
            
                        <button
                            onClick={handlePurchase}
                            className="hover:cursor-pointer bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition"
                        >
                            Purchase
                        </button>
                    </div>

                )}

                {errorMessage && (
                    <p className="text-red-500 text-sm mt-2">{errorMessage}</p>
                )}
            </div>
        </div>
    );
}