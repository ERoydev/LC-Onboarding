import { useState } from "react";
import { useOutletContext } from "react-router-dom";
import TokenData from "../../intefaces/TokenData";

export default function StartAuction() {
  // Come from outlet(parent) context
  const { tokensData, handleStartAuction, errorMessage, showError, clearError }: {
    errorMessage: string, 
    showError: (msg: string) => void, 
    clearError: () => void, 
    tokensData: TokenData[], 
    handleStartAuction: (selectedNFT: TokenData, 
    startingPrice: number, 
    duration: number) => void 
  } = useOutletContext();
  
  const [selectedNFT, setSelectedNFT] = useState<TokenData | null>(null);
  const [startingPrice, setStartingPrice] = useState("");
  const [duration, setDuration] = useState("");

  const StartAuctionClickHandler = () => {
    if (!selectedNFT || !startingPrice || !duration) {
      showError("Please select an NFT, starting price, and duration.");
      return;
    }

    if (Number(startingPrice) < 0) {
      showError("Starting price must be a positive number.");
      return;
    }

    handleStartAuction(selectedNFT, Number(startingPrice), Number(duration));
    setSelectedNFT(null);
    setStartingPrice("");
    setDuration("");
    clearError();
  };

  return (
    <div className="flex-grow p-6">
      <header className="mb-8">
        <h1 className="text-4xl font-bold">Start an Auction</h1>
        <p className="text-lg mt-2 text-gray-600">Auction your NFTs and let the bidding begin!</p>
      </header>

      <div className="bg-white shadow-lg rounded-lg p-8">
        {/* Select NFT */}
        <div className="mb-6">
          <label htmlFor="nft" className="block text-sm font-medium text-gray-700 mb-2">
            Select NFT
          </label>
          <select
            id="nft"
            value={selectedNFT?.name || ""}
            onChange={(e) =>
              setSelectedNFT(tokensData.find((nft) => nft.name === e.target.value) || null)
            }
            className="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500"
          >
            <option value="">Select an NFT</option>
            {tokensData.map((nft, idx) => (
              <option key={idx} value={nft.name}>
                {nft.name}
              </option>
            ))}
          </select>
          {selectedNFT && (
            <div className="mt-4 flex items-center gap-4">
              <img
                src={selectedNFT.image}
                alt={selectedNFT.name}
                className="w-16 h-16 object-cover rounded-lg shadow-md"
              />
              <p className="text-gray-700 font-medium">{selectedNFT.name}</p>
            </div>
          )}
        </div>

        {/* Starting Price */}
        <div className="mb-6">
          <label htmlFor="startingPrice" className="block text-sm font-medium text-gray-700 mb-2">
            Starting Price (ETH)
          </label>
          <input
            type="number"
            id="startingPrice"
            value={startingPrice}
            onChange={(e) => setStartingPrice(e.target.value)}
            placeholder="Enter starting price in ETH"
            className="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500"
          />
        </div>

        {/* Auction Duration */}
        <div className="mb-6">
          <label htmlFor="duration" className="block text-sm font-medium text-gray-700 mb-2">
            Auction Duration (Minutes)
          </label>
          <input
            type="number"
            id="duration"
            value={duration}
            onChange={(e) => setDuration(e.target.value)}
            placeholder="Enter duration in minutes (e.g., 120 for 2 hours)"
            className="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500"
          />
        </div>

        {/* Start Auction Button */}
        <button
          onClick={StartAuctionClickHandler}
          className="w-full bg-gradient-to-r from-cyan-500 to-blue-500 text-white py-3 px-4 rounded-md shadow-md hover:from-cyan-600 hover:to-blue-600 transition"
        >
          Start Auction
        </button>

        {errorMessage && <p className="text-red-500 text-sm mt-2">{errorMessage}</p>}
      </div>
    </div>
  );
}