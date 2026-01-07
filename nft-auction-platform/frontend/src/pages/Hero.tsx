import { Link } from "react-router-dom";
import SmallBanner from "../components/ui/SmallBanner";

export default function Hero() {
  return (
    <div className="flex flex-col items-center justify-center py-42 px-8">
      {/* Buy NFT Section */}
      <div className="flex gap-12 items-center justify-center max-w-[1400px]">
        {/* Text Side */}
        <div className="text-center xl:w-1/2">
          <SmallBanner title="Explore our latest NFT collections." />

          <h1 className="text-5xl font-semibold tracking-tight text-gray-800 sm:text-7xl">
            Discover and Buy Exclusive NFTs.
          </h1>

          <p className="mt-8 text-lg font-medium text-gray-500/[0.8] leading-relaxed sm:text-xl">
            Browse through our curated collection of NFTs and own unique digital assets. Secure your place in the future of digital art.
          </p>

          <div className="mt-10 flex items-center justify-center gap-x-6">
            <Link
              to="/marketplace"
              className="rounded-md bg-indigo-600 px-5 py-3 text-sm font-semibold text-white shadow-md hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              Explore NFTs
            </Link>
            <a
              href="https://www.investopedia.com/non-fungible-tokens-nft-5115211"
              className="text-sm font-semibold text-gray-900 hover:text-indigo-600 hover:underline"
            >
              Learn more <span aria-hidden="true">→</span>
            </a>
          </div>

          {/* Statistics Section */}
          <div className="mt-16 grid grid-cols-1 sm:grid-cols-2 gap-8 text-center">
            <div>
              <p className="text-4xl font-bold text-indigo-600/[0.7]">5K+</p>
              <p className="text-gray-800/[0.4]">Happy Customers</p>
            </div>

            <div>
              <p className="text-4xl font-bold text-indigo-600/[0.7]">2K+</p>
              <p className="text-gray-800/[0.4]">NFTs Sold</p>
            </div>
          </div>
        </div>

        <div className="hidden xl:block hover:cursor-pointer relative rounded-full overflow-hidden border-8 border-slate-800 shadow-lg group">
          {/* Image */}
          <img
            src="/images/hero.png"
            alt="Hero Image Mint NFT"
            className="w-[600px] h-[600px] object-cover transition-transform duration-500 group-hover:scale-110 group-hover:rotate-3 relative z-10"
          />
        </div>
      </div>
    </div>
  );
}