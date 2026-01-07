import { Link } from "react-router-dom";


export default function LargeBanner({
    title,
    description,
    link,
    linkLabel
}: {
    title: string; // Something in format like "Want to Mint More NFTs?"
    description: string; // Something in format like "Create and add new NFTs to your collection with just a few clicks."
    link?: string; // Something in format like "/mintnft"
    linkLabel?: string; // Something in format like "Mint New NFT"
}) {
    return(
        <div className="bg-gray-500/15 rounded-2xl py-8">
            <div className="text-center">
                <h3 className="text-2xl font-bold mb-2">{title}</h3>
                <p className="text-gray-600 mb-4">
                    {description}
                </p>

                {link && (
                    <Link
                        className="bg-gradient-to-r hover:cursor-pointer from-green-500 to-teal-500 text-white py-2 px-6 rounded-md shadow-md hover:from-green-600 hover:to-teal-600 transition"
                        to={link}
                    >
                        {linkLabel}
                    </Link>
                )}
            </div>
      </div>
        
    );
}