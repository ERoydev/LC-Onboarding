// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {RoleManager} from "./abstract-contracts/RoleManager.sol";
import {MerkleWhiteList} from "./abstract-contracts/MerkleWhiteList.sol";
import {ERC721Consecutive} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Consecutive.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PriceConsumer} from "./abstract-contracts/PriceConsumer.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


/*
Core Logic:
    Stores:
        - Price
        - Whitelist root
        - Chainlink oracle address

    Implements:
        - mint()
        - whitelist checks
        - ETH payment logic
        - admin functions(set price, update whitelist, etc.)
*/

/// @title Nft Contract
/// @author E.Roydev
/// @notice Used to mint nfts
contract NFT is ERC721, ERC721Burnable, RoleManager, MerkleWhiteList, PriceConsumer, ReentrancyGuard {
    uint256 private _currentTokenId;

    /// @dev to have a name when deployed
    string public contractLabel;

    /// @dev track the tokens each address owns
    mapping(address => uint256[]) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex; // inside the array of tokens that address holds gives the index of the specific tokenId (tokenId => index)
    mapping(uint256 => TokenInfo) public tokenInfo; // tokenId => TokenInfo to get metadataURL
    
    /// @dev track how much ETH each owner is owed => using in Pull over push stragegy
    mapping(address => uint256) public fundsOwed;

    event TokenMinted(address indexed user, uint256 indexed tokenId);
    event TokenPurchased(address indexed seller, address indexed receiver, uint256 indexed tokenId);

    constructor() ERC721("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // contract creator is DEFAULT_ADMIN
        contractLabel = "NFT Contract v1";
    }

    // ================================================ Price and Payment Tokens this requires me to deploy on a TESTNET

    function defaultPriceSetup() external OnlyAdminOrPaymentTokensConfigurator {
        PriceConsumer._default();
    }

    function updatePriceFeedAddress(address _newPriceFeedAddress) external OnlyAdminOrPaymentTokensConfigurator {
         require(_newPriceFeedAddress != address(0), "Invalid Price Feed address");
        PriceConsumer._updatePriceFeedAddress(_newPriceFeedAddress);
    }

    function updateUsdcTokenAddress(address _newTokenAddress) external OnlyAdminOrPaymentTokensConfigurator {
        require(_newTokenAddress != address(0), "Invalid USDC token address");
        PriceConsumer._updateUsdcTokenAddress(_newTokenAddress);
    }

    function updateSalePriceOfMarketplaceToken(uint256 _tokenId, uint256 _newUsdcPrice) external OnlyAdminOrSalesPriceManager {
        require(_tokenId < _currentTokenId, "This tokenId does not exist");
        TokenInfo storage tokenToUpdate = tokenInfo[_tokenId];
        if (tokenToUpdate.priceInUSDC == _newUsdcPrice) {
            revert("New price is the same as the current price");
        }

        tokenToUpdate.priceInUSDC = _newUsdcPrice;
    }

    // ================================================ Price and Payment Tokens



    // =============================================== Merkle Root Functions
    function setMerkleRoot(bytes32 newRoot) external OnlyAdminOrWhitelistedManager {
        MerkleWhiteList._setMerkleRoot(newRoot);
    }
    // =============================================== Merkle Root Functions

    // =============================================== TOKENS Functions

    struct TokenInfo {
        uint256 priceInUSDC;
        address owner;
        string metadataURI;
    }

    /// @notice User who mints his token is the msg.sender so he mints to himself
    function safeMint(
            string calldata tokenMetadataURL, 
            bytes32[] calldata merkleProof,
            uint256 _priceInUSDC
        ) external isWhitelisted(merkleProof) nonReentrant {

        // TODO: I don't have good error handling when user is not Whitelisted to provide a good frontend response for this problem. Currently i give general error that something went wrong.
        uint256 tokenId = _currentTokenId;
        require(bytes(tokenMetadataURL).length > 0, "Invalid metadata URL");
        _currentTokenId ++;

        // before transfer 
        _beforeTokenTransfer(address(0), msg.sender, tokenId);

        tokenInfo[tokenId] = TokenInfo({
            priceInUSDC: _priceInUSDC,
            owner: payable(msg.sender),
            metadataURI: tokenMetadataURL
        });

        _safeMint(msg.sender, tokenId);

        emit TokenMinted(msg.sender, tokenId);
    }

    // This function shall recieve eth using `nft.purchaseNFT{value: expectedETH}(1, true, addr1Proof)` type of syntax
    function purchaseNFT(
            uint256 _tokenId, 
            bool payWithETH, 
            bytes32[] calldata merkleProof
        ) external payable nonReentrant {
        
        verifyProof(msg.sender, merkleProof);
    
        TokenInfo memory tokenData = tokenInfo[_tokenId];
        require(tokenData.owner != address(0), "Token not found");
        require(ownerOf(_tokenId) == tokenData.owner, "Already sold");

        if (payWithETH) {
            uint256 requiredETH = getETHPriceForUSDCAmount(tokenData.priceInUSDC);
            require(msg.value >= requiredETH, "Insufficient ETH");
            
            // Instead of sending immediately i implement Pull-over-Push strategy
            fundsOwed[tokenData.owner] += requiredETH;

            // Older version where i send immediately
            // (bool success,) = info.owner.call{value: requiredETH}("");
            // require(success, "Transfer failed");

        } else {
            // if i use usdc i use ERC20 instructions to transfer tokens 
            // Remember user must approve that address(this) can spend this USDC => Do it in the frontend
            require(IERC20(usdcToken).transferFrom(msg.sender, tokenData.owner, tokenData.priceInUSDC), "USDC transfer failed");
        } 

        _beforeTokenTransfer(tokenData.owner, msg.sender, _tokenId);

        emit TokenPurchased(tokenData.owner, msg.sender, _tokenId);
        _transfer(tokenData.owner, msg.sender, _tokenId); // Transfers the nft from owner to the sender 
    }

    function getTokenPriceInEth(uint256 _tokenId) public view returns (uint256) {
        TokenInfo memory info = tokenInfo[_tokenId];
        require(info.owner != address(0), "Token not found");
        require(ownerOf(_tokenId) == info.owner, "Already sold");

        return getETHPriceForUSDCAmount(info.priceInUSDC);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        // I use this to apply deletion logic from _ownedTokens when for example i create action and trasnfer this token to another contract
        _beforeTokenTransfer(from, to, tokenId);
        super.transferFrom(from, to, tokenId);
    }


    // Util function
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        if (from != address(0)) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to != address(0)) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = length; 
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            // Switch the tokens position in the array to pop the last index in the end
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        _ownedTokens[from].pop();
        delete _ownedTokensIndex[tokenId];
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        // TODO: Maybe i should make checks that only owner of the tokens can retrieve this information
        return _ownedTokens[owner];
    }

    function getTokenURL(uint256 tokenId) public view returns (string memory) {
        require(tokenInfo[tokenId].owner != address(0), "Token doesn't exist");
        return tokenInfo[tokenId].metadataURI;
    }

    function withdrawFunds() external nonReentrant {
        // Pull-Over-Push strategy making owner withdraw his money from selling nft's
        uint256 amount = fundsOwed[msg.sender];
        require(amount > 0, "No funds to withdraw");

        fundsOwed[msg.sender] = 0; // Update state first

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdraw failed");
    }

    // =============================================== TOKENS Functions

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}