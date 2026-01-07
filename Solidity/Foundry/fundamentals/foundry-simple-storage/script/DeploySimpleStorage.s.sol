// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// .s.sol = is Foundry way to write this Deploy Script

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        // `vm` is a special keyword in the forge standard library. The VM is only used in Foundry. It's a Cheatcode (check it in Foundry Book)

        vm.startBroadcast(); // Everything after this line inside of this function, you should actually send to the RPC
        // Everything inside here i want to send and deploy
        SimpleStorage simpleStorage = new SimpleStorage(); // `new` creates a new contract, this sends a transaction to create a new simpleStorage contract

        vm.stopBroadcast(); // When we are done broadcasting i stop it
        return simpleStorage;
    }
}

/*
- `forge script script/DeploySimpleStorage.s.sol` in the terminal
    - If i dont specify the RPC url, it will automatically deploy to a temporary anvil chain 

- When running anvil:
    - forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
*/
