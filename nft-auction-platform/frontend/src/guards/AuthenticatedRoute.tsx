import React, { useEffect } from "react";
import { Navigate } from "react-router-dom";
import { useWallet } from "../context/Wallet/WalletContext";

interface AuthenticatedRouteProps {
  children: React.ReactNode;
  setErrorMessage?: (message: string) => void; // Optional callback to set error messages
}

const AuthenticatedRoute: React.FC<AuthenticatedRouteProps> = ({ children, setErrorMessage }) => {
  const { currentAccount } = useWallet();

  useEffect(() => {
    if (!currentAccount && setErrorMessage) {
      setErrorMessage("Connect your wallet to access this page.");
    }
  }, [currentAccount, setErrorMessage]);

  // Check if the user is logged in (wallet connected)
  if (!currentAccount) {
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
};

export default AuthenticatedRoute;