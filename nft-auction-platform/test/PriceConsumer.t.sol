// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseNFTTest} from "./BaseNFTTest.t.sol";
import { NFT} from "../src/NFT.sol";
import "forge-std/console.sol";

// Mocked contracts
import {ERC20Mock} from "../script/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../script/mocks/MockChainlinkAddress.sol";

contract PriceConsumerTest is BaseNFTTest {
    function testInitialPriceFeedAndUsdcToken() public {
        address admin = address(0x1);
        vm.startPrank(admin);

        NFT testNft = new NFT();

        vm.stopPrank();

        assertEq(testNft.usdcToken(), address(0), "Initialialy should be unset");
        assertEq(testNft.customChainlinkPriceFeedAddress(), address(0), "Initialialy should be unset");
    }

    function testDefaultPriceFeedAndUsdcToken() public {
        address admin = address(0x1);
        vm.startPrank(admin);

        NFT testNft = new NFT();

        testNft.defaultPriceSetup();

        vm.stopPrank();

        assertEq(testNft.DEFAULT_CHAINLINK_SEPOLIA_ETH_USD_CONTRACT(), DEFAULT_CHAINLINK_SEPOLIA_ETH_USD_CONTRACT_USED);
        assertEq(testNft.usdcToken(), DEFAULT_USDC_TOKEN_SEPOLIA_ADDRESS_USED);
    }


    function testUpdatePriceFeedAddress() public {
        address admin = address(0x1);
        vm.startPrank(admin);

        NFT testNft = new NFT();

        MockV3Aggregator testingPriceFeed = new MockV3Aggregator(8, 0);

        testNft.updatePriceFeedAddress(address(testingPriceFeed));

        vm.stopPrank();

        assertEq(testNft.customChainlinkPriceFeedAddress(), address(testingPriceFeed));
    }

    function testUpdateUsdcTokenAddress() public {
        address admin = address(0x1);
        vm.startPrank(admin);

        // Deploy mock USDC token
        ERC20Mock testingUsdcToken = new ERC20Mock();

        NFT testNft = new NFT();

        testNft.updateUsdcTokenAddress(address(testingUsdcToken));

        vm.stopPrank();

        assertEq(testNft.usdcToken(), address(testingUsdcToken));
    }

    function testGetETHPriceForUSDCAmount() public view {
        uint usdcAmount = 150;
        uint256 price = nft.getETHPriceForUSDCAmount(usdcAmount); // In WEI
        assertGt(price, 0, "Price should be greater than 0");
        assertEq(price, 76054495581233806);
    }
}
