import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useWallet } from "../../context/Wallet/WalletContext"; // Import useWallet hook for context

const ConnectWallet = () => {
  const [hovering, setHovering] = useState(false); // State to track hover
  const { currentAccount, connectWallet, disconnectWallet } = useWallet(); // Access the context
  const navigate = useNavigate();
  
  const handleConnectWallet = async () => {
    if (typeof window.ethereum !== "undefined") {
      const address = await connectWallet(); // Call the connectWallet function from context
      if (address) {
        window.localStorage.setItem("walletConnected", "true"); // Optional: Save connection state
      }
    } else {
      alert("MetaMask is not installed. Please install it to use this feature.");
    }
  };

  const handleDisconnectWallet = () => {
    const success = disconnectWallet(); // Call the disconnectWallet function from context
    if (success) {
      window.location.reload(); // Force a page reload to reset the provider state
    }
  };

  const handleUserSettings = () => {
    navigate("/profilemenu");
  };

  return (
    <div className="flex items-center gap-4">
      {/* User Settings Icon (Only visible when wallet is connected) */}
      {currentAccount && (
        <button
          onClick={handleUserSettings}
          className="text-gray-700 hover:text-indigo-600 hover:scale-110 transition hover:cursor-pointer"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 512 512"
            className="w-10 h-10"
            fill="currentColor"
          >
            <path d="M399 384.2C376.9 345.8 335.4 320 288 320l-64 0c-47.4 0-88.9 25.8-111 64.2c35.2 39.2 86.2 63.8 143 63.8s107.8-24.7 143-63.8zM0 256a256 256 0 1 1 512 0A256 256 0 1 1 0 256zm256 16a72 72 0 1 0 0-144 72 72 0 1 0 0 144z" />
          </svg>
        </button>
      )}

      {/* Wallet Address */}
      {currentAccount ? (
        <div
          className="flex items-center gap-2 bg-green-500 text-white rounded-full px-4 py-2 shadow-md cursor-pointer transition-all duration-300 hover:bg-red-500"
          onClick={handleDisconnectWallet}
          onMouseEnter={() => setHovering(true)} // Show "Disconnect Wallet" on hover
          onMouseLeave={() => setHovering(false)} // Revert to wallet address
        >
          <p className="text-sm font-medium">
            {hovering
              ? "Disconnect Wallet" // Show this text on hover
              : `${currentAccount.slice(0, 8)}...${currentAccount.slice(-4)}`} {/* Show wallet address */}
          </p>
        </div>
      ) : (
        <button
          onClick={handleConnectWallet}
          className="hover:cursor-pointer rounded-md bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow-md hover:bg-indigo-500 transition"
        >
          Connect Wallet
        </button>
      )}
    </div>
  );
};

export default ConnectWallet;
