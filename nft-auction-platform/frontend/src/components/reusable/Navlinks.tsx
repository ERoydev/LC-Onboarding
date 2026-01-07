import { Link, useLocation, useNavigate } from "react-router-dom";
import { useRef, useEffect } from "react";

export default function Navlinks() {
  const location = useLocation();
  const navigate = useNavigate();
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  const handleCompanyClick = () => {
    if (location.pathname === "/") {
      // If already on the home page, scroll to the "company" section
      const companySection = document.getElementById("company");
      if (companySection) {
        companySection.scrollIntoView({ behavior: "smooth" });
      }
    } else {
      // Navigate to the home page and scroll to the "company" section
      navigate("/");
      timeoutRef.current = setTimeout(() => {
        const companySection = document.getElementById("company");
        if (companySection) {
          companySection.scrollIntoView({ behavior: "smooth" });
        }
      }, 100); // Delay to ensure the page has loaded
    }
  };

  useEffect(() => {
    // Cleanup the timeout when the component unmounts
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return (
    <>
      <Link
        to="/marketplace"
        className="block text-sm font-semibold text-gray-900 hover:bg-gray-200 rounded-full p-2"
      >
        Marketplace
      </Link>
      <Link
        to="/auction"
        className="block text-sm font-semibold text-gray-900 hover:bg-gray-200 rounded-full p-2"
      >
        Auctions
      </Link>
      <Link
        to="/mintnft"
        className="block text-sm font-semibold text-gray-900 hover:bg-gray-200 rounded-full p-2"
      >
        Mint Your NFT
      </Link>
      <button
        onClick={handleCompanyClick}
        className="block text-sm font-semibold text-gray-900 hover:bg-gray-200 rounded-full p-2 hover:cursor-pointer"
      >
        Company
      </button>
    </>
  );
}