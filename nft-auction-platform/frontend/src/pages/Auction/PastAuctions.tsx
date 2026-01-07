import { useState } from "react";
import { useWallet } from "../../context/Wallet/WalletContext";
import { useFetchAuctions } from "../../hooks/useFetchAuctions";
import AuctionCard from "./reusable/AuctionCard";
import AuctionModal from "./reusable/AuctionModal";

export default function PastAuctions() {
  const { currentAccount } = useWallet();
  const { auctions, loading } = useFetchAuctions(false); // Use the hook with isActive set to false
  const [selectedAuction, setSelectedAuction] = useState(null);

  const handleAuctionClick = (auction: any) => {
    setSelectedAuction(auction); // Set the selected auction to display in the modal
  };

  const closeModal = () => {
    setSelectedAuction(null); // Close the modal
  };

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-4xl font-bold mb-6">Past Auctions</h1>
      {loading ? (
        <p>Loading past auctions...</p>
      ) : auctions.length === 0 ? (
        <p className="text-center text-gray-600">No past auctions available.</p>
      ) : (
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
          currentAccount={currentAccount ? currentAccount.toLocaleLowerCase() : ""}
          BID_VALUE={0} // No bidding value for past auctions
          isBiddable={false} // No bidding allowed for past auctions
        />
      )}
    </div>
  );
}