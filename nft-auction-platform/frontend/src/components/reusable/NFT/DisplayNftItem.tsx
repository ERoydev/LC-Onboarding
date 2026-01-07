import TokenData from "../../../intefaces/TokenData";


export default function DisplayNftItem({
    nft,
    handleCardClick
}: {
    nft: any,
    handleCardClick: (nft: TokenData) => void
}) {

    return(
        <div
        onClick={() => handleCardClick(nft)} // Handle card click
        className="rounded-lg shadow-md bg-white overflow-hidden hover:shadow-xl hover:scale-105 transition-transform duration-300 hover:cursor-pointer relative"
      >
        {/* Image */}
        <img
          src={nft.image}
          alt={`NFT ${nft.name}`}
          className="w-full h-48 object-cover"
        />

        {/* Overlay Text (NFT Name) */}
        <div className="absolute bottom-0 left-0 w-full bg-black/50 text-white text-xs text-center py-1">
          {nft.name}
        </div>

        {/* NFT Details */}
        <div className="p-4">
          <p className="text-lg font-semibold text-gray-800">
            Price: {nft.price} USDCx 
          </p>
          <p className="text-sm text-gray-600 mt-2 mb-2 border-t border-gray-500/[0.4] py-3">
            {nft.description.slice(0, 40)}{/* Slice the description */}
            {nft.description.length > 50 && "..."}{/* Add ellipsis if truncated */}
          </p>
        </div>
      </div>
    );
}