import { ethers } from "ethers";
import { ROLES } from "../pages/admin";
import { getBrowserProvider, nftReadContract, getNFtWriteContract } from "../utils/contract";
import { addToWhitelist, updateTheRoot } from "./WhitelistService";
import axios from "axios";
import { logger } from "../utils/logger";

export async function assignRole(role: string, userAddress: string, senderRole: string) {
    /*
        TODO: Have in mind that i use `Available Accounts` to get wallet address
        if i use private keys this function will not work because it expects address 
    */

    try {
        if (role == ROLES[0]) {
            logger.log("Assigning Whitelist Manager role to:", userAddress);

            const contractWithSigner = await getNFtWriteContract();

            const result = await contractWithSigner.addWhitelistManager(userAddress);
        
            // This should be added to the whitelist
            addToWhitelist(userAddress, senderRole);
            updateTheRoot();
            logger.log("Whitelist Manager role assigned:", result);

            // Should delete the roles saved in the database, because they are changed and need to be fetched again
            const deleteAddressResult = await axios.post(`${import.meta.env.VITE_BACKEND_URL}/deleteAddress/`, {
                address: userAddress,  // send the address in the body of the request
            });

            return;

        } else if (role == ROLES[1]) {
            logger.log("Assigning Sales Price Manager role to:", userAddress);

            const contractWithSigner = await getNFtWriteContract();

            const result = await contractWithSigner.addSalesPriceManager(userAddress);
            logger.log("Sales Price Manager role assigned:", result);

            // Should delete the roles saved in the database, because they are changed and need to be fetched again
            const deleteAddressResult = await axios.post(`${import.meta.env.VITE_BACKEND_URL}/deleteAddress/`, {
              address: userAddress,  // send the address in the body of the request
            });

            return;

        } else if (role == ROLES[2]) {
            logger.log("Assigning Payment Tokens Configurator role to:", userAddress);

            const contractWithSigner = await getNFtWriteContract();

            const result = await contractWithSigner.addPaymentTokensConfigurator(userAddress);
            logger.log("Payment Tokens Configurator role assigned:", result);
            return;

            // Should delete the roles saved in the database, because they are changed and need to be fetched again
            const deleteAddressResult = await axios.post(`${import.meta.env.VITE_BACKEND_URL}/deleteAddress/`, {
              address: userAddress,  // send the address in the body of the request
          });
        }

        throw new Error("Invalid Role");
    } catch (error) {
        logger.error("Error assigning role:", error);
        throw error;
    }
}


export const getRoles = async (account: string) => {
  if (typeof window.ethereum === 'undefined') {
    throw new Error('Metamask is not installed.');
  } 

  try {
    // Send a POST request with the account address in the JSON body
    const response = await axios.post(`${import.meta.env.VITE_BACKEND_URL}/roles/`, {
      address: account,  // send the address in the body of the request
    });

    const roles = response.data.roles;
    // TODO: roles using index like that is not scalabe solution for this feature
    return {
      isAdmin: roles[0],
      isWhitelistManager: roles[1],
      isSalesPriceManager: roles[2],
      isPaymentTokensConfigurator: roles[3],
    };
  } catch (error) {
    logger.error('Error fetching roles:', error);
    // Return default values if there's an error
    return {
      isAdmin: false,
      isWhitelistManager: false,
      isSalesPriceManager: false,
      isPaymentTokensConfigurator: false,
    };
  }
};
