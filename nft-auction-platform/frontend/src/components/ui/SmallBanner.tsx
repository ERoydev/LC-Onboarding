import { Link } from "react-router-dom";

interface SmallBannerProps {
    title: string;
}

export default function SmallBanner({title}: SmallBannerProps
) {
    return(
        <div className="hidden sm:mb-8 sm:flex sm:justify-center">
            <div className="relative rounded-full px-3 py-1 text-sm/6 text-gray-600 ring-1 ring-gray-900/10 hover:ring-gray-900/20">
              {title}{" "}
              <Link to="/marketplace" className="font-semibold text-indigo-600">
                <span className="absolute inset-0" aria-hidden="true"></span>
                View now <span aria-hidden="true">&rarr;</span>
              </Link>
            </div>
          </div>
    );
}