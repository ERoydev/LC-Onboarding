// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


/// @dev - Tested in Remix on Sepolia it works
/// @notice - When NFT is deployed this Price Configurations will not be set until specifically is called:
/// .updated.... or .default() instructions
abstract contract PriceConsumer {
    address public usdcToken; // USDC Token contract

    AggregatorV3Interface internal priceFeed; // PriceFeed contract here
    address public DEFAULT_CHAINLINK_SEPOLIA_ETH_USD_CONTRACT = 0x694AA1769357215DE4FAC081bf1f309aDC325306; 
    address public customChainlinkPriceFeedAddress; // allow PriceFeed to be updated

    // https://sepolia.ethplorer.io/address/0x94a9d9ac8a22534e3faca9f4e7f2e2cf85d5e4c8#
    address private DEFAULT_USDC_TOKEN_SEPOLIA_ADDRESS = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    event ChainlinkPriceFeedIsUpdated(address indexed updatedBy, address newPriceFeed);
    event DefaultSepoliaPriceSetup();
    event USDCTokenAddressChanged(address indexed updatedBy, address indexed newTokenAddress);

    // Function to get the latest ETH/USD price from the Chainlink feed
    function _getLatestPrice() internal view returns (int) {
        (
             , // Ignore roundID
            int price, 
            , // Ignore startedAt
            , // Ignore timeStamp
            // Ignore answeredInRound
        ) = priceFeed.latestRoundData();
        
        // Return the current price (in 8 decimal places)
        return price; // Will be USD price for 1 ETH, but scaled by 8 decimal places => for Precission to the last cent
        // Example 196727477529, it represents $1967.27 for 1 ETH.
        // 196727477529 / 100000000 = 1967.27....
    }

    function getETHPriceForUSDCAmount(uint256 _usdcAmount) public view returns (uint256) {
        // REMEMBER: => When working with money, i should always do calculations with as much decimals as possible(precission),
        // and only round or format for display
        
        int256 price = _getLatestPrice(); // returns ETH/USD with 8 decimals
        require(price > 0, "Invalid price");

        uint256 ethPrice = uint256(price); // still 8 decimals
        // Scale USDC amount from 6 decimals to 18 to match ETH wei
        // And do the division considering price has 8 decimals
        uint256 ethAmountInWei = (_usdcAmount * 1e18 * 1e8) / ethPrice;

        return ethAmountInWei;
    }


    // =================================== Configuration set instructions
    function _updatePriceFeedAddress(address _newPriceFeedAddress) internal {
        require(_newPriceFeedAddress != address(priceFeed), "Price Feed address is the same as the current active one");
        customChainlinkPriceFeedAddress = _newPriceFeedAddress;
        priceFeed = AggregatorV3Interface(_newPriceFeedAddress);

        emit ChainlinkPriceFeedIsUpdated(msg.sender, _newPriceFeedAddress);
    }

    function _updateUsdcTokenAddress(address _newUsdcTokenAddress) internal {
        require(_newUsdcTokenAddress != usdcToken, "USDC token address is the same as the current active one");
        usdcToken = _newUsdcTokenAddress;
        
        emit USDCTokenAddressChanged(msg.sender, _newUsdcTokenAddress);
    }

    function _default() internal {
        priceFeed = AggregatorV3Interface(DEFAULT_CHAINLINK_SEPOLIA_ETH_USD_CONTRACT);
        usdcToken = DEFAULT_USDC_TOKEN_SEPOLIA_ADDRESS;

        emit DefaultSepoliaPriceSetup();
    }
}
