// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MerkleWhiteList abstract contract
 * @dev Manages all the logic for storing the merkleRoot and verification of proofs required to interact with NFT contract
 */
abstract contract MerkleWhiteList {
    // using MerkleProof for bytes32[];

    bytes32 public merkleRoot;  

    event MerkleRootUpdated(bytes32 newMerkleRoot);
    
    modifier isWhitelisted(bytes32[] calldata merkleProof) {
        require(MerkleWhiteList.verifyProof(msg.sender, merkleProof), "this account is not whitelisted");
        _;
    }

    /// @dev - User will get the proof for his account from backend/server and then reconstruct the root and verify it on-chain
    function verifyProof(address account, bytes32[] calldata merkleProof) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(account));
        return MerkleProof.verify(merkleProof, merkleRoot, leaf); 
    }

    /// @dev - Admin just updates the root without any checks.
    function _setMerkleRoot(bytes32 newRoot) internal {
        merkleRoot = newRoot;
        emit MerkleRootUpdated(newRoot);
    }
}