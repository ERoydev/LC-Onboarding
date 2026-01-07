import { useState, useEffect } from "react";
import { useFetchAuctions } from "../../hooks/useFetchAuctions";
import { endAuction, placeBidAuction } from "../../services/AuctionService";
import { useError } from "../../hooks/useError";
import { useWallet } from "../../context/Wallet/WalletContext";
import { AuctionDetails } from "../../intefaces/AuctionDetails";
import AuctionCard from "./reusable/AuctionCard";
import AuctionModal from "./reusable/AuctionModal";


export default function ActiveAuction() {
  const {currentAccount, tokensData} = useWallet();
  const { loading, auctions: fetchedAuctions, refetch } = useFetchAuctions(); // Use the hook directly
  const [auctions, setAuctions] = useState<AuctionDetails[]>([]);
  const [selectedAuction, setSelectedAuction] = useState<AuctionDetails | null>(null);
  const [showSuccess, setShowSuccess] = useState(false); // State for success effect
  const { errorMessage, showError } = useError(); // Hook to manage error messages]
  const BID_VALUE = 1;

  useEffect(() => {
    setAuctions(fetchedAuctions); // Update auctions whenever fetchedAuctions changes
  }, [fetchedAuctions]);

  const handleAuctionClick = (auction: AuctionDetails) => {
    setSelectedAuction(auction); // Set the selected auction to display in the modal
  };

  const closeModal = () => {
    setSelectedAuction(null); // Close the modal
  };

  const handlePlaceBid = async () => {
    if (!selectedAuction) return;

    const newBid = parseFloat(selectedAuction.highestBid) + BID_VALUE;

    const bidResult = await placeBidAuction(selectedAuction.auctionId, newBid.toString());

    if (bidResult.error) {
      showError("Failed to place bid. Please try again.");
      return;
    }

    setShowSuccess(true); // Show success effect
    setTimeout(() => setShowSuccess(false), 2000); // Hide success effect after 2 seconds
    setSelectedAuction(null);
    // ✅ Refetch auctions after placing a bid
    refetch(); // Trigger the hook to fetch the latest auctions
  };  

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-4xl font-bold mb-6">Active Auctions</h1>
      {loading ? (
        <p>Loading auctions...</p>
      ) : auctions.length === 0 ? (
        <p className="text-center text-gray-600">No active auctions currently.</p>
      ): (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8">
          {auctions.map((auction, idx) => (
            <AuctionCard auction={auction} handleAuctionClick={handleAuctionClick} key={idx} />
          ))}
        </div>
      )}

      {/* Modal */}
      {selectedAuction && (
        <AuctionModal 
          selectedAuction={selectedAuction}
          closeModal={closeModal}
          handlePlaceBid={handlePlaceBid}
          currentAccount={currentAccount? currentAccount.toLocaleLowerCase() : ""}
          BID_VALUE={BID_VALUE}
          isBiddable={true}
        />
      )}

      {/* Success Effect */}
      {showSuccess && (
        <div className="fixed inset-0 bg-green-500 bg-opacity-50 flex items-center justify-center z-50">
          <div className="text-white text-2xl font-bold">
            🎉 Bid Placed Successfully!
          </div>
        </div>
      )}
    </div>
  );
}