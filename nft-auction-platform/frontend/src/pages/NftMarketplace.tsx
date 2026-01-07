import { useState } from "react";
import { useFetchTokenUrls } from "../hooks/useFetchTokenUrls";
import Spinner from "../components/reusable/Spinner";
import { useWallet } from "../context/Wallet/WalletContext";
import { getMerkleProof } from "../services/WhitelistService";
import { purchaseNFT } from "../services/nftContractService";
import DisplayNftList from "../components/reusable/NFT/DisplayNftList";
import DisplayNftModal from "../components/reusable/NFT/DisplayNftModal";
import TokenData from "../intefaces/TokenData";
import { useError } from "../hooks/useError";


export default function NFTMarketplace({
  title
}: {
  title: string;
}) {
  const { currentAccount, refetch } = useWallet(); // Get the user's wallet address from context
  const { tokensData, loading, removeToken } = useFetchTokenUrls(import.meta.env.VITE_OWNER_OF_CONTRACTS); // Use the custom hook
  const [selectedNFT, setSelectedNFT] = useState<TokenData | null>(null); // State for selected NFT
  const [isModalOpen, setIsModalOpen] = useState(false); // State for modal visibility
  const [payWithETH, setPayWithETH] = useState(false); // State for "Pay with ETH" option
  const { showError, errorMessage } = useError();

  const handleCardClick = (nft: TokenData) => {
    setSelectedNFT(nft); // Set the selected NFT
    setIsModalOpen(true); // Open the modal
  };

  const handlePurchase = async () => {
    if (!selectedNFT) return;
    if (!currentAccount) {
      alert("Please connect your wallet to purchase an NFT.");
      return;
    }

    // Add your purchase logic here
    const merkleProof = await getMerkleProof(currentAccount);

    const purchaseResult = await purchaseNFT(selectedNFT.tokenId, payWithETH, merkleProof, selectedNFT.price);
    
    if (purchaseResult.error) {
      showError(purchaseResult.error); // Show error message
      return;
    }
    // Close the modal after purchase
    setIsModalOpen(false);
    removeToken(selectedNFT.tokenId); // Remove the purchased token from the list
    refetch(); // Refetch the userWallet data to update the changes.
  };

  const closeModal = () => {
    setIsModalOpen(false); // Close the modal
    setSelectedNFT(null); // Clear the selected NFT
    setPayWithETH(false); // Reset the "Play with ETH" option
  };
  

  return (
    <div className="py-32 px-6 sm:px-12 lg:px-24 min-h-screen">
      <h1 className="text-4xl font-bold text-center text-purple-800/60 mb-12">
        {title}
      </h1>

      {loading ? ( // Show loading indicator while loading
        <Spinner />
      ) : tokensData.length === 0 ? (
        <div className="text-center text-gray-600 text-lg">
          No listed NFTs available.
        </div>
      ) : (
        <DisplayNftList tokensData={tokensData} handleCardClick={handleCardClick}/>
      )}

      {/* Modal */}
      {isModalOpen && selectedNFT && (
        <DisplayNftModal 
          closeModal={closeModal} 
          selectedNft={selectedNFT} 
          handlePurchase={handlePurchase} 
          payWithETH={payWithETH}
          setPayWithETH={setPayWithETH}
          errorMessage={errorMessage}
        />
      )}

    </div>
  );
}