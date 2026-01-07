import { Route, Routes } from "react-router-dom";
import BottomBackgroundBlur from "./components/background/BottomBackgroundBlur";
import TopBackgroundBlur from "./components/background/TopBackgroundBlur";
import Header from "./components/common/Header";
import NFTMarketplace from "./pages/NftMarketplace";
import MintNFT from "./pages/MintNFT";
import Footer from "./components/common/Footer";
import Home from "./pages/Home";
import Company from "./pages/Company";
import ProfileMenu from "./pages/Profile/ProfileMenu";
import AdminPanel from "./pages/admin/AdminPanel";
import Auction from "./pages/Auction/Auction";
import { WalletProvider } from "./context/Wallet/WalletContext";
import AuthenticatedRoute from "./guards/AuthenticatedRoute";
import { useState } from "react";
import AdminRoute from "./guards/AdminGuard";
import StartAuction from "./pages/Auction/StartAuction";
import ActiveAuction from "./pages/Auction/ActiveAuctions";
import PastAuctions from "./pages/Auction/PastAuctions";
import ErrorMessageComponent from "./components/reusable/ErrorMessageComponent";
import NotFound from "./components/common/NotFound";

function App() {
  const [errorMessage, setErrorMessage] = useState("");

  return (
    <div className="bg-white">
      <div className="relative isolate px-6 pt-14 lg:px-8">
        <WalletProvider>
          <TopBackgroundBlur />
          <Header />
            <Routes>
              {/* Public Routes */}
              <Route path="/" element={<Home />} />
              <Route path="/marketplace" element={<NFTMarketplace title={"NFT Marketplace"} />} />
              <Route path="/company" element={<Company />} />

              {/* Routes for Logged-In Wallets */}
              <Route
                // Auction Routes
                path="/auction"
                element={
                  <AuthenticatedRoute setErrorMessage={setErrorMessage}>
                    <Auction />
                  </AuthenticatedRoute>
                }
                >
                  <Route path="start" element={<StartAuction  />} />
                  <Route path="active" element={<ActiveAuction />} />
                  <Route path="past" element={<PastAuctions />} />
                </Route>

              <Route path="/mintnft" element={
                <AuthenticatedRoute setErrorMessage={setErrorMessage}>
                  <MintNFT />
                </AuthenticatedRoute>
                } 
              />

              <Route path="/profilemenu" element={
                <AuthenticatedRoute setErrorMessage={setErrorMessage}>
                  <ProfileMenu />
                </AuthenticatedRoute>
                } 
              />

              {/* Admin Routes*/}
              
              <Route path="/admin" element={
                <AdminRoute setErrorMessage={setErrorMessage}>
                  <AdminPanel />
                </AdminRoute>
                } 
              />
              
              <Route path="*" element={<NotFound />} />

            </Routes>
          <BottomBackgroundBlur />
        </WalletProvider>
      </div>

      {errorMessage && <ErrorMessageComponent message={errorMessage} />}
      <Footer />
    </div>
  );
}

export default App;
