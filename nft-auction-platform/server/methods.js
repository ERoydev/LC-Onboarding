import { ethers } from "ethers";
import { nftContract } from "./contract.js";

export async function getRolesForUser(userAddress) {
    try {
        
        const normalizedAddress = ethers.getAddress(userAddress);
        const roles = await nftContract.getRoles(normalizedAddress);
        return roles;
    } catch (error) {
        console.error("Error settings role:", error);
    }
}