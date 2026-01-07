// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";
import "forge-std/console.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "./mocks/MockChainlinkAddress.sol";
import {EnglishAuction} from  "../src/EnglishAuction.sol";

// forge script script/DeployLocally.s.sol --rpc-url $ANVIL_RPC_URL --private-key $ANVIL_CONTRACT_ADMIN --broadcast --ffi

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        address adminAddress = vm.envAddress("INITIAL_ADMIN_ADDRESS");  // Replace with your actual admin address

        // Deploy The Mock contract
        ERC20Mock erc20Mock = new ERC20Mock();

        // Deploy the Mock Chainlink Price Feed;
        MockV3Aggregator chainlinkPriceFeed = new MockV3Aggregator(8, 2000 * 10**8); // price of ETH in USD

        // Generate merkle Root for the admin address
        bytes32 merkleRoot = keccak256(abi.encodePacked(adminAddress));

        // Deploy the NFT contract
        NFT nft = new NFT();
        EnglishAuction auction = new EnglishAuction();

        nft.setMerkleRoot(merkleRoot); // Set admin in whitelist

        nft.updatePriceFeedAddress(address(chainlinkPriceFeed)); // To setup the deployed Chainlink Price Feed
        nft.updateUsdcTokenAddress(address(erc20Mock)); // setup usdToken mock


        console.log("Deployed ERC20 Mock of USDC Token contract with an address: ", address(erc20Mock));
        console.log("Deployed Chainlink Mock contract with an address: ", address(chainlinkPriceFeed));
        console.log("Deployed NFT contract with an address: ",  address(nft));
        console.log("Deployed Auction contract with an address: ", address(auction));

        vm.stopBroadcast();
    }
}

/*
Helping Notes:
1. Have in mind you should deploy mock ERC20 token and mint to some account tokens 
2. You need to approve smart contract to spend these tokens in order to do purchase from marketplace
*/

// == Logs ==
//   Deployed ERC20 Mock of USDC Token contract with an address:  0x5FbDB2315678afecb367f032d93F642f64180aa3
//   Deployed Chainlink Mock contract with an address:  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
//   Deployed NFT contract with an address:  0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
//   Deployed Auction contract with an address:  0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9