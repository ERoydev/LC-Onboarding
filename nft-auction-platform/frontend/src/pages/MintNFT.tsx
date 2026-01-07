import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { uploadFileToPinata } from "../services/Pinata";
import { mintNFT } from "../services/nftContractService";
import { getMerkleProof } from "../services/WhitelistService";
import { useWallet } from "../context/Wallet/WalletContext";
import ControlledForm from "../components/forms/ControlledForm";

export default function MintNFT() {
  const [isMinting, setIsMinting] = useState(false);
  const { currentAccount, refetch } = useWallet();
  const navigate = useNavigate();

  const handleFormSubmit = async (formData: {
    name: string;
    description: string;
    image: File | null;
    price: string;
  }) => {
    const { name, description, image, price } = formData;

    if (!name || !description || !image || !price) {
      alert("Please fill out all fields, upload an image, and set a price.");
      return;
    }

    try {
      setIsMinting(true);

      if (typeof window.ethereum === "undefined") {
        alert("MetaMask is not installed. Please install it to mint NFTs.");
        return;
      }

      // TODO: Price is string, should be number
      const { metadataURL } = await uploadFileToPinata(name, description, image, price);

      const userAddress = currentAccount;
      if (!userAddress) {
        alert("No wallet connected. Please connect your wallet.");
        return;
      }

      const merkleProof = await getMerkleProof(userAddress);

      const priceInUSDCx = parseFloat(price);
      if (isNaN(priceInUSDCx) || priceInUSDCx <= 0) {
        alert("Please enter a valid price.");
        return;
      }

      const result = await mintNFT(metadataURL, merkleProof, priceInUSDCx);
      
      if (result.error) { 
        alert("Error minting NFT. Check if you are whitelisted.");
        navigate("/");
        return;
      }

      alert("NFT minted successfully!");
      refetch();
      navigate("/");
    } catch (error) {
      console.error("Error minting NFT:", error);
      alert("Failed to mint NFT. Please try again.");
    } finally {
      setIsMinting(false);
    }
  };

  return (
    <div className="flex flex-col lg:flex-row items-center justify-between gap-12 px-6 sm:px-12 lg:px-24 py-36">
      {/* Left Section: Image */}
      <div className="lg:w-1/2 hover:cursor-pointer">
        <img
          src="https://preview.redd.it/dflp7uclewj81.png?auto=webp&s=3f5da3e1c3007b118389f663f326cbc430f50257"
          alt="Mint NFT Illustration"
          className="w-full h-auto rounded-lg shadow-lg transition-transform duration-500 hover:scale-105"
        />
      </div>

      {/* Right Section: Form */}
      <div className="lg:w-1/2">
        <h2 className="text-4xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-cyan-500 to-blue-500 mb-6 text-center lg:text-left">
          Mint Your NFT
        </h2>
        <ControlledForm onSubmit={handleFormSubmit} isSubmitting={isMinting} />
      </div>
    </div>
  );
}