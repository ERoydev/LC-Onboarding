// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { NFT} from "../src/NFT.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// Mocked contracts
import {ERC20Mock} from "../script/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../script/mocks/MockChainlinkAddress.sol";

/*
The whole points of this is because in all of the files i test the NFT contract:
But i test the abstract contracts in seperate files, so i can reuse a base setup

Test using: `forge coverage --no-match-coverage script` to exclude script from coverage stats
*/


abstract contract BaseNFTTest is Test {
    NFT public nft;

    ERC20Mock public usdcToken;
    MockV3Aggregator public chainlinkPriceFeed;

    address public owner;
    address public addr1;
    address public addr2;

    bytes32[] public addr1Proof = [
        bytes32(0x1468288056310c82aa4c01a7e12a10f8111a0560e72b700555479031b86c357d),
        bytes32(0x5b70e80538acdabd6137353b0f9d8d149f4dba91e8be2e7946e409bfdbe685b9)
    ];

    bytes32[] public ownerProof = [
        bytes32(0xd52688a8f926c816ca1e079067caba944f158e764817b83fc43594370ca9cf62),
        bytes32(0x5b70e80538acdabd6137353b0f9d8d149f4dba91e8be2e7946e409bfdbe685b9)
    ];

    bytes32 public merkleRoot = bytes32(0x344510bd0c324c3912b13373e89df42d1b50450e9764a454b2aa6e2968a4578a);
    string TOKEN_METADATA_URI = "https://example.com/tokenMetadata.json";

    address DEFAULT_CHAINLINK_SEPOLIA_ETH_USD_CONTRACT_USED = 0x694AA1769357215DE4FAC081bf1f309aDC325306; 
    address DEFAULT_USDC_TOKEN_SEPOLIA_ADDRESS_USED = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    function setUp() public {

        owner = address(0x1);
        addr1 = address(0x2);
        addr2 = address(0x3);

        // Deploy mock USDC token
        usdcToken = new ERC20Mock();

        vm.startPrank(owner);

        // Deploy Mocked Chainlink Price Feed
        // Second parameter is the answer that this mock will return on latestRoundPrice for example
        chainlinkPriceFeed = new MockV3Aggregator(8, 197227000000);

        // Deploy NFT contract with mock usdc and price feed address ()
        nft = new NFT();

        nft.updatePriceFeedAddress(address(chainlinkPriceFeed)); // I update it to change from default to custom
        nft.updateUsdcTokenAddress(address(usdcToken)); // Set mock usdc token address

        nft.setMerkleRoot(merkleRoot);

        vm.stopPrank();
    }
    
    // Util function used to test the proof logic it is the same used in the abstract contract MerkleWhiteList.sol
    function verifyProof(address account, bytes32[] memory merkleProof) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(account));
        return MerkleProof.verify(merkleProof, merkleRoot, leaf); 
    }
}