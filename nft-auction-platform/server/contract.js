import { ethers } from 'ethers';
import dotenv from 'dotenv';

dotenv.config();

const nftContractABI = [
  {
    "type": "function",
    "name": "getRoles",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "_Admin",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "_WhitelistManager",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "_SalesPriceManager",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "_PaymentTokensConfigurator",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
];
  

// Connect to Sepolia
console.log('SEPLIA RPC:', process.env.SEPOLIA_RPC);
const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC); 


// Create a signer useing the admin's private key
const adminPrivateKey = process.env.ADMIN_PRIVATE_KEY;
const signer = new ethers.Wallet(adminPrivateKey, provider);

// Contract addresses
const nftContractAddress = process.env.NFT_CONTRACT_ADDRESS;

// Create contract instance
const nftContract = new ethers.Contract(nftContractAddress, nftContractABI, signer);

export { provider, nftContract };


