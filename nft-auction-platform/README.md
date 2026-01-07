<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>nft-auction-web3</title>
</head>
<body>

  <h1>nft-auction-web3</h1>
  <p>A full-stack Web3 dApp that allows users to mint, purchase, and auction NFTs using ETH or USDC. Chainlink oracles fetch real-time ETH/USD prices. NFT metadata is stored using Pinata (IPFS), and minting/purchasing is restricted to whitelisted users via Merkle trees.</p>

  <h2>Features</h2>
  <ul>
    <li>Whitelist-based minting and purchasing</li>
    <li>Pay with ETH or USDC (Chainlink price feed for ETH)</li>
    <li>NFT metadata pinned to IPFS via Pinata</li>
    <li>English auction with escrowed bidding and refunds</li>
    <li>Role-based access control (Admin, Sales Manager)</li>
    <li>Full smart contract test suite with Foundry</li>
  </ul>

  <h2>Stack</h2>
  <ul>
    <li><strong>Smart Contracts:</strong> Solidity (using Foundry)</li>
    <li><strong>Frontend:</strong> React.js</li>
    <li><strong>Backend:</strong> Express.js</li>
    <li><strong>Oracle:</strong> Chainlink ETH/USD</li>
    <li><strong>Storage:</strong> Pinata (IPFS)</li>
  </ul>

  <h2>Project Structure</h2>
  <ul>
    <li><code>/contracts</code> – NFT and Auction contracts</li>
    <li><code>/frontend</code> – React-based frontend app</li>
    <li><code>/backend</code> – Express.js backend for whitelist verification</li>
    <li><code>/script</code> – Deployment scripts (for local and testnet)</li>
  </ul>

  <h2>Installation</h2>

  <h3>1. Install dependencies</h3>

  <p><strong>Frontend:</strong></p>
  <pre><code>cd frontend
npm install</code></pre>

  <p><strong>Backend:</strong></p>
  <pre><code>cd backend
npm install</code></pre>

  <p><strong>Contracts:</strong></p>
  <pre><code>forge install</code></pre>

  <h2>Local Development</h2>
  <ul>
    <li>Use Foundry’s <code>anvil</code> to spin up a local chain.</li>
    <li>Run <code>DeployLocally</code> script to deploy contracts with mocked Chainlink and USDC.</li>
    <li>Frontend and backend will connect to this local setup.</li>
  </ul>

  <h2>Contracts Overview</h2>

  <h3>NFT Contract</h3>
  <ul>
    <li>Inherits: OpenZeppelin ERC721 + RoleManager + MerkleWhitelist + PriceConsumer</li>
    <li><code>safeMint()</code>: Mint NFT if whitelisted</li>
    <li><code>purchaseNFT()</code>: Purchase minted NFT using ETH or USDC</li>
  </ul>

  <h3>Auction Contract</h3>
  <ul>
    <li><code>createAuction()</code>: List an NFT for auction</li>
    <li><code>placeBid()</code>: Place bid with escrow</li>
    <li><code>withdraw()</code>: Withdraw bids after losing</li>
    <li><code>endAuction()</code>: End auction and transfer NFT</li>
  </ul>

  <h2>Testing</h2>

  <p><strong>Run all Foundry tests:</strong></p>
  <pre><code>forge test -vvv</code></pre>

  <p><strong>Generate coverage (ignoring script files):</strong></p>
  <pre><code>forge coverage --no-match-coverage script</code></pre>

  <h2>Deployment</h2>
  <ul>
    <li>Smart contracts deployed to Sepolia using Forge scripts</li>
    <li>Frontend hosted on <a href="https://render.com">Render</a></li>
  </ul>

</body>
</html>

# NOTES FOR MYSELF DEVELOPMENT 
## Usefull links
- https://dev.to/jamiescript/design-patterns-in-solidity-1i28
- https://www.cyfrin.io/blog/what-is-a-reentrancy-attack-solidity-smart-contracts
- https://docs.ipfs.tech/how-to/best-practices-for-nft-data/

1. forge script .... Deploy the NFT contract
2. node script/CopyABI.js to update the abi contract in the frontend
3. update the .env's with the new contract address (frontend/foundry)
4. mint NFT's again since they are all losted

# Locally the anvil addresses that i use are:
- (0): I use for deployment (DEFAULT_ADMIN) -> Account 2 in metamask
- (9): I use for WhitelistManager -> Account 4 in metamask

# Errors that occured during developments that are good to note

## 1. When i work on JS/TS and i want to hash address which my smart contract expects as bytes32
 - Backend was hashing addresses with just keccak256(address) — a plain string hash — while smart contract likely expected keccak256(abi.encodePacked(address)) like Solidity  does. That mismatch is why the proofs were invalid (resulting in false in cast call).
 - solidityPackedKeccak256(...) = mimics abi.encodePacked + keccak256 from Solidity
 - If the hash of your leaf in JS doesn’t match the one Solidity expects, the Merkle proof won’t validate — ever.
