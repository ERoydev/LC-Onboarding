

export default function WithdrawWindow({
    label,
    valueToWithdraw,
    description,
    handleWithdrawClick,
    errorMessage,
}: {
    label: string;
    valueToWithdraw: number;
    description: string;
    handleWithdrawClick: () => void;
    errorMessage: string | null;
}) {

    return(
        <div className="mt-8 p-6 bg-white rounded-lg shadow-md border border-gray-200">
            <h2 className="text-xl font-semibold text-gray-800 mb-4">{label}</h2>
            <p className="text-gray-600">
            You have
            <span className="font-bold text-indigo-600 mx-1">{valueToWithdraw} ETH</span>
            {description}
            </p>
            <button
            onClick={handleWithdrawClick} // Replace with actual withdraw logic
            className="hover:cursor-pointer mt-4 px-6 py-2 bg-indigo-600 text-white font-semibold rounded-md shadow hover:bg-indigo-500 transition-colors"
            >
            Withdraw Funds
            </button>

            {errorMessage && (
            <p className="text-red-500 text-sm mt-2">{errorMessage}</p>
            )}
      </div>
    );
}