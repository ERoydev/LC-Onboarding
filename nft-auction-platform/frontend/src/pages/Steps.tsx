import HeaderText from "../components/ui/HeaderText";

export default function StepsSection() {
    const steps = [
      {
        id: 1,
        title: "Connect",
        description: "Connect your wallet to get started with our platform.",
        icon: "/images/connect.svg",
      },
      {
        id: 2,
        title: "Buy",
        description: "Browse and purchase exclusive NFTs from our marketplace.",
        icon: "/images/buy.svg",
      },
      {
        id: 3,
        title: "Auction",
        description: "List your NFTs for auction and attract potential buyers.",
        icon: "/images/auction.svg",
      },
      {
        id: 4,
        title: "Make Profit",
        description: "Sell your NFTs and earn profits directly to your wallet.",
        icon: "/images/profit.svg",
      },
    ];
  
    return (
      <div className="px-6 sm:px-12 lg:px-24">
        <div className="text-center">
          <HeaderText title="How It Works" />

        </div>
        {/* <h2 className="text-4xl font-bold text-center text-gray-800 mb-12">
          How It Works
        </h2> */}
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-8">
          {steps.map((step) => (
            <div
              key={step.id}
              className="hover:cursor-pointer flex flex-col items-center text-center bg-white rounded-lg shadow-md p-6 hover:shadow-xl hover:scale-105 hover:bg-gray-200/70 transition-all duration-300"
            >
              <div className="text-5xl mb-4 transform transition-transform duration-300 group-hover:rotate-12">
                <img src={step.icon} className="w-25 h-25" alt="icon" />
              </div>
              <h3 className="text-xl font-semibold text-gray-800 mb-2">
                {step.title}
              </h3>
              <p className="text-gray-600">{step.description}</p>
            </div>
          ))}
        </div>
      </div>
    );
  }