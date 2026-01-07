import { Link, useLocation, Outlet } from "react-router-dom";
import TokenData from "../../intefaces/TokenData";
import { useWallet } from "../../context/Wallet/WalletContext";
import { createAuction } from "../../services/AuctionService";
import { useError } from "../../hooks/useError";
import {past, active, started} from "./index";
import InstructionCard from "../../components/ui/InstructionCard";

export default function Auction() {
  const { tokensData, removeToken } = useWallet();
  const location = useLocation(); // Get the current route
  const { showError, errorMessage, clearError } = useError();

  const handleStartAuction = async (selectedNFT: TokenData, startingPrice: number, duration: number) => {
    const data = {
      tokenId: selectedNFT.tokenId,
      startingPrice: startingPrice,
      duration: duration,
    };

    const auctionCreationResult = await createAuction(data);

    if (auctionCreationResult.error) {
      showError(auctionCreationResult.error);
      return;
    }

    alert(`Auction started for ${selectedNFT.name}!`);
    removeToken(selectedNFT.tokenId); // Remove the NFT from the list after starting the auction
  };

  return (
    <div className="flex flex-col lg:flex-row min-h-screen my-22 py-12 bg-gray-500/20 rounded-2xl">
      {/* Sidebar */}
      <div className="w-full lg:w-1/4 p-6 rounded-lg">
        <h2 className="text-2xl font-bold mb-6">Auction Menu</h2>

        {/* NAVIGATION */}
        <nav className="space-y-4">
          <Link
            to="/auction/start"
            className={`flex items-center gap-3 text-lg font-semibold rounded-lg p-3 ${
              location.pathname === "/auction/start"
                ? "bg-gray-200 text-cyan-500"
                : "text-gray-900 hover:bg-gray-200"
            }`}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 384 512"
              className="w-5 h-5"
            >
              <path d="M73 39c-14.8-9.1-33.4-9.4-48.5-.9S0 62.6 0 80L0 432c0 17.4 9.4 33.4 24.5 41.9s33.7 8.1 48.5-.9L361 297c14.3-8.7 23-24.2 23-41s-8.7-32.2-23-41L73 39z" />
            </svg>
            Start an Auction
          </Link>
          <Link
            to="/auction/active"
            className={`flex items-center gap-3 text-lg font-semibold rounded-lg p-3 ${
              location.pathname === "/auction/active"
                ? "bg-gray-200 text-cyan-500"
                : "text-gray-900 hover:bg-gray-200"
            }`}
          >
            <svg
              className="w-5 h-5"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 512 512"
            >
              <path d="M64 64c0-17.7-14.3-32-32-32S0 46.3 0 64L0 400c0 44.2 35.8 80 80 80l400 0c17.7 0 32-14.3 32-32s-14.3-32-32-32L80 416c-8.8 0-16-7.2-16-16L64 64zm406.6 86.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L320 210.7l-57.4-57.4c-12.5-12.5-32.8-12.5-45.3 0l-112 112c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L240 221.3l57.4 57.4c12.5 12.5 32.8 12.5 45.3 0l128-128z" />
            </svg>
            Active Auctions
          </Link>
          <Link
            to="/auction/past"
            className={`flex items-center gap-3 text-lg font-semibold rounded-lg p-3 ${
              location.pathname === "/auction/past"
                ? "bg-gray-200 text-cyan-500"
                : "text-gray-900 hover:bg-gray-200"
            }`}
          >
            <svg
              className="w-5 h-5"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 384 512"
            >
              <path d="M192 0c-41.8 0-77.4 26.7-90.5 64L64 64C28.7 64 0 92.7 0 128L0 448c0 35.3 28.7 64 64 64l256 0c35.3 0 64-28.7 64-64l0-320c0-35.3-28.7-64-64-64l-37.5 0C269.4 26.7 233.8 0 192 0zm0 64a32 32 0 1 1 0 64 32 32 0 1 1 0-64zM112 192l160 0c8.8 0 16 7.2 16 16s-7.2 16-16 16l-160 0c-8.8 0-16-7.2-16-16s7.2-16 16-16z" />
            </svg>
            Past Auctions
          </Link>
        </nav>
      </div>

      {/* Initial Page */}  
      {location.pathname === "/auction" && (
        <div className="p-8 rounded-lg shadow-md">
          <h2 className="text-3xl font-bold text-gray-800 mb-6 text-center">Auction Details</h2>
          <p className="text-md text-gray-600 leading-relaxed text-center mb-8">
            Manage your auctions effortlessly. Start new auctions, track active ones, and review past auctions. Explore the future of NFT trading with ease.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Start Auction */}
            <InstructionCard 
              imgUrl="/images/started.svg"
              title="Start an Auction"
              description="Create a new auction for your NFTs and set your desired starting price and duration."
            />

            {/* Active Auctions */}
           <InstructionCard 
            imgUrl="/images/active.svg"
            title="Active Auctions"
            description="Monitor your ongoing auctions, track bids, and manage your NFT sales in real-time."
           />

            {/* Past Auctions */}
            <InstructionCard 
              imgUrl="/images/past.svg"
              title="Past Auctions"
              description="Review the history of your completed auctions and analyze your NFT trading performance."
            />
          </div>
        </div>     
      )}

      <div className="flex-grow p-6">
        <Outlet context={{ tokensData, handleStartAuction, removeToken, errorMessage, showError, clearError }} />
      </div>
    </div>
  );
}