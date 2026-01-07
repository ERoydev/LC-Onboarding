// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";
import {EnglishAuction} from  "../src/EnglishAuction.sol";

/*
Deploy with the following command in terminal:
    - `forge script script/DeploySepolia.s.sol --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast`
    - Make sure you have set SEPOLIA_RPC => https://sepolia.infura.io/v3/....from infura or alchemy code here 
    - And Private Key for example exported from your metamask => Account details
*/


contract Deploy is Script {
    // Admin address to be hashed into the Merkle Root
    address adminAddress = vm.envAddress("INITIAL_ADMIN_ADDRESS");  // Replace with your actual admin address

    function run() external {
        vm.startBroadcast();

        // Generate merkle Root for the admin address
        bytes32 merkleRoot = keccak256(abi.encodePacked(adminAddress));

        EnglishAuction auction = new EnglishAuction();
        NFT nft = new NFT();

        nft.defaultPriceSetup(); // set the default Sepolia addresses i have configured for the Chainlink Price Feed and UsdcToken

        nft.setMerkleRoot(merkleRoot);

        vm.stopBroadcast();
    }
}

// ✅  [Success] Hash: 0xa04306f655bd98d187e69536b0669095d1f9a99fee39526a5f53ef50c820746a
// Contract Address: 0x12Bf05D7999eC07DA92309D8F2Ab4D48dAD74099
// Block: 8313089
// Paid: 0.000001820512486818 ETH (1820487 gas * 0.001000014 gwei)


// ##### sepolia
// ✅  [Success] Hash: 0x1fd3aa50b112506a373ba6a5f328f9b9eefdf4ef5bca78c639fc53bfeddf760b
// Contract Address: 0x8c556283f339EF8946D307F0D72992F91eB5d2A7
// Block: 8313089
// Paid: 0.000005393218504002 ETH (5393143 gas * 0.001000014 gwei)
