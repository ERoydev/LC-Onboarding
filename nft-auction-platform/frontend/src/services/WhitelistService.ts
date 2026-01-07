import axios from "axios"
import { ethers } from "ethers";
import {arrayify} from "@ethersproject/bytes";
import { getBrowserProvider, nftReadContract, getNFtWriteContract} from "../utils/contract";
import { logger } from "../utils/logger";

// Used only from admins to add/remove users from the whitelist

const SERVER_URL = "http://localhost:3000";


export async function getMerkleProof(userAddress: string) {
    try {
        const response = await axios.post(`${SERVER_URL}/getProof`, {
            address: userAddress,
        });
        
        // Its an array of hex strings
        
        const proofHex = response.data.proof;
        const proofBytes32 = proofHex.map((hexString: string) => arrayify(hexString));
   
        return proofBytes32;

    } catch (error) {
        logger.error("Error fetching Merkle proof:", error);
        throw error;
    }
}

export async function addToWhitelist(walletAddress: string, senderRole: string) {
    const wallet = walletAddress.trim();

    try {
        // Add whitelist to the json file on the server
        const response = await axios.post(`${SERVER_URL}/addAddress`, {
            address: wallet,
            senderRole: senderRole,
        });
        
        // Update the merkle root in the smart contract
        updateTheRoot();

        return response.data;
    } catch (error) {
        logger.error("Error adding to whitelist:", error);
        if (error.response.data == "Address already exists in the whitelist") {
            alert("Address already exists in the whitelist");
        }
        throw error;
    }
}

export async function removeFromWhitelist(walletAddress: string, senderRole: string) {
    const wallet = walletAddress.trim();

    try {
        // Remove whitelist from the json file on the server
        const response = await axios.post(`${SERVER_URL}/removeAddress`, {
            address: wallet,
            senderRole: senderRole,
        });

        // Update the merkle root in the smart contract
        updateTheRoot();

        return response.data;
    } catch (error) {
        logger.error("Error removing from whitelist:", error);
        if (error.response.data == "Address does not exist in the whitelist") {
            alert("Address does not exist in the whitelist");
        }
        throw error;
    }
}


export async function updateTheRoot() {
    // Only Default admin and Whitelist Manager can update the root
    try {
        const response = await axios.get(`${SERVER_URL}/getMerkleRoot`);

        const newRoot = response.data.merkleRoot;

        const contractWithSigner = await getNFtWriteContract();

        await contractWithSigner.setMerkleRoot(newRoot);

    } catch (error) {
        logger.error("Error updating the root:", error);
        throw error;
    }
}