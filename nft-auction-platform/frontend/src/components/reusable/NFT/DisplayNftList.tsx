import TokenData from "../../../intefaces/TokenData";
import DisplayNftItem from "./DisplayNftItem";


export default function DisplayNftList({
    tokensData,
    handleCardClick,
}: {
    tokensData: TokenData[];
    handleCardClick: (nft: TokenData) => void;
}) {
    return(
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
          {tokensData.map((nft, idx) => (
            <DisplayNftItem key={idx} nft={nft} handleCardClick={handleCardClick}/>
          ))}
        </div>
    );
}