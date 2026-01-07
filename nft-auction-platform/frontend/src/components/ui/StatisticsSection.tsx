

export default function StatisticsSection() {
    return(
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">

          <div className="bg-white shadow-lg rounded-lg p-6 text-center">
            <h3 className="text-2xl font-bold text-purple-600 mb-2">Total NFTs Minted</h3>
            <p className="text-4xl font-bold text-gray-800">1,234</p>
          </div>

          <div className="bg-white shadow-lg rounded-lg p-6 text-center">
            <h3 className="text-2xl font-bold text-green-600 mb-2">Total Whitelisted Users</h3>
            <p className="text-4xl font-bold text-gray-800">567</p>
          </div>

          <div className="bg-white shadow-lg rounded-lg p-6 text-center">
            <h3 className="text-2xl font-bold text-blue-600 mb-2">Platform Revenue (ETH)</h3>
            <p className="text-4xl font-bold text-gray-800">89.45</p>
          </div>
      </div>
    );
}