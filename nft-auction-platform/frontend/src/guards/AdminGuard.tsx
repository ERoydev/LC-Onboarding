import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useWallet } from "../context/Wallet/WalletContext";

interface AdminRouteProps {
  children: React.ReactNode;
  setErrorMessage: (msg: string) => void;
}
const AdminRoute: React.FC<AdminRouteProps> = ({ children, setErrorMessage }) => {
  const {
    currentAccount,
    isAdmin,
    isWhitelistManager,
    isSalesPriceManager,
    isPaymentTokensConfigurator,
    loadingRoles, // new from WalletContext
  } = useWallet();

  const navigate = useNavigate();

  useEffect(() => {
    if (loadingRoles) return; // Wait until roles are loaded

    if (currentAccount === null) return; // Or handle no account case as needed

    const hasAccess =
      isAdmin || isWhitelistManager || isSalesPriceManager || isPaymentTokensConfigurator;

    if (!hasAccess) {
      setErrorMessage("You are not authorized to access this page.");
      navigate("/", { replace: true });
    }
  }, [
    currentAccount,
    isAdmin,
    isWhitelistManager,
    isSalesPriceManager,
    isPaymentTokensConfigurator,
    loadingRoles,
    navigate,
    setErrorMessage,
  ]);

  if (loadingRoles || currentAccount === null) {
    return null; // or spinner
  }

  return <>{children}</>;
};

export default AdminRoute;