// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title RoleManager
 * @dev Manages roles using AccessControl. Roles include:
 * - WHITELIST_MANAGER
 * - SALES_PRICE_MANAGER
 * - PAYMENT_TOKENS_CONFIGURATOR
 * This gives me ready to use methods like: _grantRole(), hasRole(), _revokeRole() and modifier onlyRole() out of the box.
 * 
 * The NFT Collection that is on the Marketplace sold by us is going to be minted from DEFAULT_ADMIN
 */
abstract contract RoleManager is AccessControl {
    bytes32 public constant WHITELIST_MANAGER = keccak256("WHITELIST_MANAGER"); // Whitelist allows who can mint/purchase nft's
    bytes32 public constant SALES_PRICE_MANAGER = keccak256("SALES_PRICE_MANAGER"); // Markeplace NFT price management
    bytes32 public constant PAYMENT_TOKENS_CONFIGURATOR = keccak256("PAYMENT_TOKENS_CONFIGURATOR"); // Configure the supported payment tokens -> (USDC Chainlin Oracle Logic)

    event WhitelistManagerAdded(address indexed account);
    event WhitelistManagerRemoved(address indexed account);
    event SalesPriceManagerAdded(address indexed account);
    event SalesPriceManagerRemoved(address indexed account);
    event PaymentTokensConfiguratorAdded(address indexed account);
    event PaymentTokensConfiguratorRemoved(address indexed account);

    // =============================================== Ownership Modifiers
    modifier onlyWhitelistManager() {
        require(hasRole(WHITELIST_MANAGER, msg.sender), "not a whitelist manager");
        _;
    }

    modifier OnlyAdminOrWhitelistedManager() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(WHITELIST_MANAGER, msg.sender),
        "Not an admin or a whitelist manager"
        );
        _;
    }

    modifier OnlyAdminOrPaymentTokensConfigurator() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(PAYMENT_TOKENS_CONFIGURATOR, msg.sender),
        "Not an admin or Payment tokens configurator"
        );
        _;
    }

    modifier OnlyAdminOrSalesPriceManager() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SALES_PRICE_MANAGER, msg.sender),
        "Not an admin or Saler price manager"
        );
        _;
    }
    // =============================================== Ownership Modifiers

    function getRoles(address account) external view returns (
        bool _Admin,
        bool _WhitelistManager,
        bool _SalesPriceManager,
        bool _PaymentTokensConfigurator
    ) {
        _Admin = hasRole(DEFAULT_ADMIN_ROLE, account);
        _WhitelistManager = hasRole(WHITELIST_MANAGER, account);
        _SalesPriceManager = hasRole(SALES_PRICE_MANAGER, account);
        _PaymentTokensConfigurator = hasRole(PAYMENT_TOKENS_CONFIGURATOR, account);
    }

    

    // =============================================== Role Assignment Instructions Bellow
    function isAdmin(address account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addWhitelistManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(WHITELIST_MANAGER, account);
        emit WhitelistManagerAdded(account);
    }

    function removeWhitelistManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(WHITELIST_MANAGER, account);
        emit WhitelistManagerRemoved(account);
    }

    function isWhitelistManager(address account) external view returns (bool) {
        return hasRole(WHITELIST_MANAGER, account);
    }

    function addSalesPriceManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(SALES_PRICE_MANAGER, account);
        emit SalesPriceManagerAdded(account);
    }

    function removeSalesPriceManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(SALES_PRICE_MANAGER, account);
        emit SalesPriceManagerRemoved(account);
    }

    function isSalesPriceManager(address account) external view returns (bool) {
        return hasRole(SALES_PRICE_MANAGER, account);
    }

    function addPaymentTokensConfigurator(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(PAYMENT_TOKENS_CONFIGURATOR, account);
        emit PaymentTokensConfiguratorAdded(account);
    }

    function removePaymentTokensConfigurator(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(PAYMENT_TOKENS_CONFIGURATOR, account);
        emit PaymentTokensConfiguratorRemoved(account);
    }

    function isPaymentTokensConfigurator(address account) external view returns (bool) {
        return hasRole(PAYMENT_TOKENS_CONFIGURATOR, account);
    }
}
