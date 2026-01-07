import { createContext, useState, useContext, ReactNode, useEffect } from 'react';
import { getRoles } from '../../services/RolesService';
import { useFetchTokenUrls } from '../../hooks/useFetchTokenUrls';
import { ethers } from 'ethers';
import { logger } from '../../utils/logger';
/*
Keeps track of the current wallet address, connect, disconnect, and roles of the user:
  - Added functionality to fetch roles from the smart contract.
  - Added functionality to listen for account changes in MetaMask.
*/

// TODO: Need to find the most optimal way to fetch the roles from smart contract and store them in a way i dont make too many requests. Possile solution is to use backend memoization

interface WalletContextType {
  currentAccount: string | null;
  connectWallet: () => Promise<void>;
  disconnectWallet: () => boolean;
  isAdmin: boolean;
  isWhitelistManager: boolean;
  isSalesPriceManager: boolean;
  isPaymentTokensConfigurator: boolean; 
  tokensData: any[]; // Add the type for tokensData
  removeToken: (tokenId: number) => void; // Add the type for removeToken
  refetch: () => void; // Add the type for refetch
  loadingRoles: boolean; // Add the type for loadingRoles
}

const WalletContext = createContext<WalletContextType | undefined>(undefined);

interface WalletProviderProps {
  children: ReactNode;
}

export const WalletProvider = ({ children }: WalletProviderProps) => {
  const [currentAccount, setCurrentAccount] = useState<string | null>(null);
  const { tokensData, removeToken, refetchData: refetch } = useFetchTokenUrls(currentAccount);
  const [loadingRoles, setLoadingRoles] = useState(true);

  const [roles, setRoles] = useState({
    isAdmin: false,
    isWhitelistManager: false,
    isSalesPriceManager: false,
    isPaymentTokensConfigurator: false,
  });


  // Connect to wallet (MetaMask)
  const connectWallet = async (): Promise<void> => {
    if (typeof window.ethereum !== 'undefined') {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const normalizedAddress = ethers.getAddress(accounts[0]); // Normalize the address
  
        setCurrentAccount(normalizedAddress);
        window.localStorage.setItem('walletConnected', normalizedAddress);
  
        // Fetch roles after wallet is connected
        await fetchRoles(normalizedAddress);
  
      } catch (error) {
        logger.error('Error connecting wallet:', error);
        alert('Failed to connect wallet');
      }
    } else {
      alert('MetaMask is not installed. Please install it to use this feature.');
    }
  };
  

  // Disconnect wallet
  const disconnectWallet = (): boolean => {
    setCurrentAccount(null);
    window.localStorage.removeItem('walletConnected');
    return true;
  };

  // Reconnect functionality: On component mount, try to reconnect if a wallet address is stored in localStorage
  useEffect(() => {
    const storedAccount = window.localStorage.getItem('walletConnected');
    if (storedAccount) {
      setCurrentAccount(storedAccount);
      fetchRoles(storedAccount); // Fetch roles if an account is stored
    }

    // Listen for MetaMask account changes
    if (typeof window.ethereum !== 'undefined') {
      const handleAccountsChanged = (accounts: string[]) => {
        if (accounts.length > 0) {
          const normalizedAddress = ethers.getAddress(accounts[0]);
          setCurrentAccount(normalizedAddress);
          window.localStorage.setItem('walletConnected', normalizedAddress);
          fetchRoles(normalizedAddress);
          refetch();
        } else {
          setCurrentAccount(null);
          window.localStorage.removeItem('walletConnected');
          refetch();
        }
      };
      
      // Add the event listener for account changes
      if (window.ethereum?.on) {
        window.ethereum.on('accountsChanged', handleAccountsChanged);
      }

      // Clean up listener on component unmount
      return () => {
        if (window.ethereum?.removeListener) {
          window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
        }
      };
    }
  }, []);


  // Fetch roles from smart contract whenever currentAccount changes
  const fetchRoles = async (account: string) => {
    setLoadingRoles(true);
    if (account) {
      const roles = await getRoles(account);
      setRoles(roles);
    }
    setLoadingRoles(false);
  };

  return (
    <WalletContext.Provider
      value={{
        currentAccount,
        connectWallet,
        disconnectWallet,
        isAdmin: roles.isAdmin,
        isWhitelistManager: roles.isWhitelistManager,
        isSalesPriceManager: roles.isSalesPriceManager,
        isPaymentTokensConfigurator: roles.isPaymentTokensConfigurator,
        tokensData,
        removeToken,
        refetch, // Expose refetch function to refresh tokensData
        loadingRoles,
      }}
    >
      {children}
    </WalletContext.Provider>
  );
};

// Custom hook to use WalletContext
export const useWallet = (): WalletContextType => {
  const context = useContext(WalletContext);
  if (!context) {
    throw new Error('useWallet must be used within a WalletProvider');
  }
  return context;
};
