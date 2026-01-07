
`database.json` => Is used to store user permissions:
// The fetch command is in frontend/services/RoleService.ts => fetchRolesFromSmartContract() method
- t returns it in the following format with boolean values:
```rust
return {
    isAdmin: roles[0],
    isWhitelistManager: roles[1],
    isSalesPriceManager: roles[2],
    isPaymentTokensConfigurator: roles[3],
};
```