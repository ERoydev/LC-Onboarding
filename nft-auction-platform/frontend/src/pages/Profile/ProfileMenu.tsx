import { useEffect, useState } from "react";
import { useWallet } from "../../context/Wallet/WalletContext";
import { fetchUserBidHistory, getLockedAuctionFunds, withdrawAuctionProfit, withdrawDepositedFunds } from "../../services/AuctionService";
import BidHistory from "../../components/reusable/BidHistory";
import DisplayNftList from "../../components/reusable/NFT/DisplayNftList";
import TokenData from "../../intefaces/TokenData";
import LargeBanner from "../../components/ui/LargeBanner";
import DisplayNftModal from "../../components/reusable/NFT/DisplayNftModal";
import { getLockedNftFunds, withdrawFunds } from "../../services/nftContractService";
import emptyNft from "../../intefaces/EmptyNft";
import { useError } from "../../hooks/useError";
import WithdrawWindow from "../../components/ui/WithdrawWindow";


export default function ProfileMenu() {
  const { currentAccount, tokensData } = useWallet();
  const [bidHistory, setBidHistory] = useState<any[]>([]);
  const [loadingBids, setLoadingBids] = useState(false);
  const [selectedNft, setSelectedNft] = useState<TokenData | null>(null);

  // States to manage locked funds
  const [lockedNftFunds, setLockedNftFunds] = useState<number>(0);
  // Auction withdraw state variables
  const [soldAuctions, setSoldAuctions] = useState([]);
  const [depositedFunds, setDepositedFunds] = useState<number>(0);
  const [auctionDepositedIDs, setAuctionDepositedIDs] = useState([]);

  const { showError, errorMessage } = useError();

  const handleCardClick = (nft: TokenData) => { 
    setSelectedNft(nft);
  }

  const closeModal = () => {
    setSelectedNft(null);
  }

  useEffect(() => {
    const fetchBids = async () => {
      if (currentAccount) {
        setLoadingBids(true);
        const bids = await fetchUserBidHistory(currentAccount);
        setBidHistory(bids);
        setLoadingBids(false);
      }
    };

    fetchBids();
  }, [currentAccount]);

  useEffect(() => {
    const fetchNftLockedFunds = async () => {
      if (currentAccount) {
        const nftFunds = await getLockedNftFunds(currentAccount);
        setLockedNftFunds(nftFunds);
      }
    };

    const fetchAuctionLockedFunds = async () => {
      if (currentAccount) {
        const result: any = await getLockedAuctionFunds(currentAccount);

        if (result.depositedFunds) {
          setDepositedFunds(result?.depositedFunds);
        }

        if (result.soldAuctions) {
          setSoldAuctions(result?.soldAuctions);
        }

        if (result.auctionDepositedIds) {
          setAuctionDepositedIDs(result?.auctionDepositedIds);
        }
      }
    }
    fetchNftLockedFunds();
    fetchAuctionLockedFunds();
  }, [currentAccount]);
  

  const withdrawLockedFunds = async () => {
    if (currentAccount) {
      const withdrawResult: any = await withdrawFunds();

      if (withdrawResult.error) {
        showError(withdrawResult.error);
        return;
      }

      setLockedNftFunds(0);
    }
  }

  const withdrawDepositedFundsHandler = async () => {
    if (currentAccount) {
      for (let i = 0; i < auctionDepositedIDs.length; i++) {
        const auctionId = auctionDepositedIDs[i];
        const withdrawResult: any = await withdrawDepositedFunds(auctionId);

        if (withdrawResult.error) {
          showError(withdrawResult.error);
          return;

        }
        setDepositedFunds(0);
        setAuctionDepositedIDs([]);
      }
    }
  }

  const withdrawFinishedAuctionFunds = async (auctionId: number) => {
    if (currentAccount) {
      const withdrawResult: any = await withdrawAuctionProfit(auctionId);

      if (withdrawResult.error) {
        showError(withdrawResult.error);
        return;
      }
      setSoldAuctions((prevAuctions) => prevAuctions.filter((auction: any) => auction.auctionId !== auctionId));
    }
  }

  return (
    <div className="flex flex-col min-h-screen py-22">
      {/* Main Content */}
      <div className="flex-grow p-6 pb-22">
        <header className="from-cyan-500 to-blue-500 py-8">
          <div className="text-center">
            <h1 className="text-4xl font-bold mb-2">Welcome to Your NFT Collection</h1>
            <p className="text-lg">Explore and manage your digital assets in one place.</p>
          </div>
        </header>

        <p className="text-center text-gray-600 mb-8">
          Below is a list of NFTs you own. Click on an NFT to view more details or manage it.
        </p>

        {/* NFT LIST SECTION */}
        {tokensData.length === 0 ? (
          <DisplayNftList tokensData={[emptyNft]} handleCardClick={(_nft: TokenData) => {}}/>
        ) : (
          <DisplayNftList tokensData={tokensData} handleCardClick={handleCardClick}/>
        )}
        
        {/* NFT List */}
        {/*
        <DisplayNftList tokensData={tokensData} handleCardClick={handleCardClick}/>

        {/* Modal */} 
        {selectedNft && (
          <DisplayNftModal closeModal={closeModal} selectedNft={selectedNft}/>
        )}
     
        {/* Bid History Section */}
        <BidHistory loading={loadingBids} bidHistory={bidHistory} />
      </div>

      {/* Withdraw Functionality */}
      <div className="pb-10">
         {/* Locked Funds */}
         <WithdrawWindow 
          key="1"
          label="Locked Funds"
          valueToWithdraw={lockedNftFunds}
          handleWithdrawClick={withdrawLockedFunds}
          description="locked funds in the NFT contract that you can withdraw."
          errorMessage={errorMessage}
        />

        <WithdrawWindow 
          key="2"
          label="Auction Funds"
          valueToWithdraw={Number(depositedFunds) / 1e18}
          handleWithdrawClick={withdrawDepositedFundsHandler} // Replace with actual withdraw logic
          description="deposited funds in the auctions which you are not a winned and you can withdraw your bids."
          errorMessage={errorMessage}
        />

        {/* Auctions ended */}
        <div className="mt-8 p-6  rounded-lg shadow-md border border-gray-200">
          <h2 className="text-xl font-semibold text-gray-800 mb-4">Auctions Ended</h2>
          {soldAuctions.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {soldAuctions.map((auction: any) => (
                <div key={auction.auctionId} className="p-4 bg-white rounded-lg shadow-md border border-gray-200 hover:bg-gray-100">
                  <p className="text-gray-600 font-bold">Auction Id: {auction.auctionId}</p>
                  <p className="text-gray-600">Highest Bidder: {auction.highestBidder}</p>
                  <p className="text-gray-600">Highest Bid: {auction.highestBid} ETH</p>

                  <button className="primary-button" onClick={() => withdrawFinishedAuctionFunds(auction.auctionId)}>Withdraw</button>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-600">No auctions ended.</p>
          )}
        </div>
      </div>

      {/* Mint Suggestions banner */}
     <LargeBanner 
        title="Want to Mint More NFTs?"
        description="Create and add new NFTs to your collection with just a few clicks."
        link="/mintnft" 
        linkLabel="Mint New NFT"
     />

    </div>
  );
}