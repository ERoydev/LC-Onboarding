import { useState } from "react";
import ConnectWallet from "../reusable/ConnectWallet";
import Navlinks from "../reusable/Navlinks";
import { Link} from "react-router-dom";
import { useWallet } from "../../context/Wallet/WalletContext";

export default function Navigation() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <nav className="flex items-center justify-between p-10 lg:px-8" aria-label="Global">
      {/* Logo */}
      <div className="flex lg:flex-1">
        <Link to="/" className="-m-1.5 p-1.5">
          <span className="text-2xl font-bold text-indigo-600 tracking-wide hover:cursor-pointer p-2">
            Auctionize
          </span>
        </Link>
      </div>

      {/* Mobile Menu Button */}
      <div className="flex lg:hidden">
        <button
          type="button"
          className="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        >
          <span className="sr-only">Open main menu</span>
          <svg
            className="h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth="1.5"
            stroke="currentColor"
            aria-hidden="true"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
            />
          </svg>
        </button>
      </div>

      {/* Desktop Navigation */}
      <div className="hidden lg:flex lg:gap-x-12">
        <Navlinks />
      </div>

      {/* Desktop Login */}
      <div className="hidden lg:flex lg:flex-1 lg:justify-end">
        <ConnectWallet />
      </div>

      {/* Mobile Menu */}
      {mobileMenuOpen && (
        <div className="absolute top-0 left-0 z-10 w-full bg-white p-6 lg:hidden">
          <div className="flex items-center justify-between">
            <Link to="/" className="-m-1.5 p-1.5">
              <span className="text-2xl font-bold text-indigo-600 tracking-wide hover:cursor-pointer p-2">
                Auctionize
              </span>
            </Link>
            <button
              type="button"
              className="-m-2.5 rounded-md p-2.5 text-gray-700"
              onClick={() => setMobileMenuOpen(false)}
            >
              <span className="sr-only">Close menu</span>
              <svg
                className="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
          <div className="mt-6 space-y-4">
            <Navlinks />
            <ConnectWallet />
          </div>
        </div>
      )}
    </nav>
  );
}