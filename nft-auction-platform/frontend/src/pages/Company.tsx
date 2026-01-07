import HeaderText from "../components/ui/HeaderText";

export default function Company() {
  return (
    <div id="company" className="flex flex-col lg:flex-row items-center justify-between gap-12 px-6 sm:px-12 lg:px-24 py-52">
      {/* Text Section */}
      <div className="lg:w-1/2 text-center">
        <HeaderText title="About Our Company" />
        <p className="text-lg text-gray-600 leading-relaxed">
          We are a pioneering platform in the NFT space, empowering creators and collectors to explore the future of digital ownership. Our mission is to provide a seamless and secure experience for buying, selling, and trading NFTs. Join us in shaping the future of the metaverse and unlocking the full potential of digital art and blockchain technology.
        </p>
      </div>

      {/* Image Section */}
      <div className="lg:w-1/2 grid grid-cols-1 sm:grid-cols-2 gap-6">
        {/* Row 1 */}
        <div className="relative group hover:cursor-pointer">
          <img
            src="https://miro.medium.com/v2/resize:fit:1024/1*8TCgRM5ed9hrU-Fs7PBkWg.png"
            alt="NFT Example 1"
            className="w-full h-full object-cover rounded-lg shadow-lg transition-transform duration-500 group-hover:scale-105 group-hover:rotate-2"
          />
          <div className="absolute inset-0 bg-indigo-600/30 opacity-0 group-hover:opacity-100 transition-opacity duration-500 rounded-lg"></div>
        </div>
        <div className="relative group hover:cursor-pointer">
          <img
            src="https://cdn.vectorstock.com/i/500p/29/46/bored-ape-nft-isolated-on-white-background-non-vector-42802946.jpg"
            alt="NFT Example 2"
            className="w-full h-full object-cover rounded-lg shadow-lg transition-transform duration-500 group-hover:scale-105 group-hover:-rotate-2"
          />
          <div className="absolute inset-0 bg-indigo-600/30 opacity-0 group-hover:opacity-100 transition-opacity duration-500 rounded-lg"></div>
        </div>

        {/* Row 2 */}
        <div className="relative group hover:cursor-pointer">
          <img
            src="https://thewealthmastery.io/wp-content/uploads/2022/08/free-nft-mint-1024x536.jpg"
            alt="NFT Example 3"
            className="w-full h-full object-cover rounded-lg shadow-lg transition-transform duration-500 group-hover:scale-105 group-hover:rotate-2"
          />
          <div className="absolute inset-0 bg-indigo-600/30 opacity-0 group-hover:opacity-100 transition-opacity duration-500 rounded-lg"></div>
        </div>
        <div className="relative group hover:cursor-pointer">
          <img
            src="https://miro.medium.com/v2/resize:fit:750/1*14_wveqASB9SnVj7kPgZAw.jpeg"
            alt="NFT Example 4"
            className="w-full h-full object-cover rounded-lg shadow-lg transition-transform duration-500 group-hover:scale-105 group-hover:-rotate-2"
          />
          <div className="absolute inset-0 bg-indigo-600/30 opacity-0 group-hover:opacity-100 transition-opacity duration-500 rounded-lg"></div>
        </div>
      </div>
    </div>
  );
}