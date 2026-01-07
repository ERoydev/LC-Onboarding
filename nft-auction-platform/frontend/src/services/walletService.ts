import { logger } from "../utils/logger";

export const connectWallet = async (): Promise<string | null> => {
    if (typeof window.ethereum !== "undefined") {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        return accounts[0]; // Return the first connected account
      } catch (error) {
        logger.error("Error connecting to wallet:", error);
        return null;
      }
    } else {
      alert("MetaMask is not installed. Please install it to use this feature.");
      return null;
    }
};

export const disconnectWallet = (): boolean => {
    try {
      // Clear any app-level state (if needed)
      // MetaMask does not provide a direct disconnect method, so we simulate it
      if (typeof window.ethereum !== "undefined") {
        window.localStorage.removeItem("walletConnected"); // Optional: Clear any stored wallet connection state
      }
      return true; // Return true to indicate successful disconnection
    } catch (error) {
      logger.error("Error disconnecting wallet:", error);
      return false; // Return false if an error occurs
    }
  };