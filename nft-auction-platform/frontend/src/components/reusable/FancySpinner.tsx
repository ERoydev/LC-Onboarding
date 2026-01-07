export default function FancySpinner() {
    return (
        <div className="min-h-screen not-only-of-type:relative flex justify-center items-center -mt-50">
            {/* Spinning Circle */}
            <div className="absolute animate-spin rounded-full h-48 w-48 border-t-4 border-b-4 border-purple-500"></div>

            {/* Image */}
            <img
                src="https://www.svgrepo.com/show/509001/avatar-thinking-9.svg"
                className="rounded-full h-44 w-44"
                alt="Loading"
            />

            {/* Loading Text */}
            <div className="absolute top-[calc(50%+110px)] text-lg font-semibold text-gray-700">
                Loading...
            </div>
        </div>
    );
}