import { Link } from "react-router-dom";

export default function Footer() {
    return (
      <footer className="w-full bg-[#333] text-gray-300 py-10 relative z-10">
        {/* Solid Background Overlay */}
        <div className="absolute inset-0 bg-[#333] opacity-95"></div>
  
        {/* Footer Content */}
        <div className="relative max-w-7xl mx-auto px-6 sm:px-12 lg:px-24">
          <div className="flex flex-col lg:flex-row justify-between items-center gap-8">
            {/* Logo and Description */}
            <div className="text-center lg:text-left">
                <div className="flex items-center gap-5">
                    <img className="w-10 h-10" src="/auctionize-logo.svg"/>
                    <h2 className="text-3xl font-bold text-white">Auctionize</h2>
                </div>
              <p className="text-sm mt-2 max-w-xs">
                Empowering creators and collectors in the NFT space. Join us in shaping the future of digital ownership.
              </p>
            </div>
  
            {/* Navigation Links */}
            <div className="flex flex-wrap justify-center lg:justify-start gap-6">
              <Link to="/marketplace" className="text-sm font-medium hover:text-white transition">
                Marketplace
              </Link>
              <Link to="/mintnft" className="text-sm font-medium hover:text-white transition">
                Mint NFT
              </Link>
              <Link to="/auction" className="text-sm font-medium hover:text-white transition">
                Auctions
              </Link>
              <Link to="/company" className="text-sm font-medium hover:text-white transition">
                Company
              </Link>
            </div>
  
            {/* Social Media Links */}
            <div className="flex gap-6">
              <a
                href="https://twitter.com"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:opacity-80 transition"
              >
                <img
                  src="https://upload.wikimedia.org/wikipedia/commons/5/5a/X_icon_2.svg"
                  alt="Twitter"
                  className="w-8 h-8"
                />
              </a>
              <a
                href="https://discord.com"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:opacity-80 transition"
              >
                <img
                  src="https://www.svgrepo.com/show/353655/discord-icon.svg"
                  alt="Discord"
                  className="w-8 h-8"
                />
              </a>
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:opacity-80 transition"
              >
                <img
                  src="https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png"
                  alt="Instagram"
                  className="w-8 h-8"
                />
              </a>
            </div>
          </div>
  
          {/* Divider */}
          <div className="border-t border-gray-500 mt-8"></div>
  
          {/* Copyright Section */}
          <div className="mt-6 text-center text-sm text-gray-400">
            © {new Date().getFullYear()} Auctionize. All rights reserved.
          </div>
        </div>
      </footer>
    );
  }