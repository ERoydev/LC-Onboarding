// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseNFTTest} from "./BaseNFTTest.t.sol";
import { NFT} from "../src/NFT.sol";

// Mocked contracts
import {ERC20Mock} from "../script/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../script/mocks/MockChainlinkAddress.sol";


contract MerkleWhiteListTest is BaseNFTTest {

    address nonWhitelistedUser = address(0x4);

    function testVerifyProofValid() public view {
        bool isValid = verifyProof(addr1, addr1Proof);
        assertTrue(isValid, "Whitelisted user should have a valid proof.");
    }

    function testIsWhitelisted() public {
        // Fail scenario
        bytes32 emptyBytes32 = 0x0;
        vm.startPrank(nonWhitelistedUser);
        vm.expectRevert("this account is not whitelisted");
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = emptyBytes32;
        nft.safeMint(TOKEN_METADATA_URI, proof, 123);
        vm.stopPrank();

        // Success scenario
        vm.startPrank(addr1);
        nft.safeMint(TOKEN_METADATA_URI, addr1Proof, 123);
        vm.stopPrank();
    }

    function testSetMerkleRoot() public {
        bytes32 newRoot = bytes32(keccak256("newRoot"));

        // Only admin can set the Merkle root
        vm.startPrank(owner);
        nft.setMerkleRoot(newRoot);
        assertEq(nft.merkleRoot(), newRoot, "Merkle root should be updated.");
        vm.stopPrank();

        // Non-admin should not be able to set the root
        vm.startPrank(addr1);
        vm.expectRevert();
        nft.setMerkleRoot(newRoot); // Non-admin should fail
        vm.stopPrank();
    }

    
}