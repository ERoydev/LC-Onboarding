// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// .s.sol = is Foundry way to write this Deploy Script

import {Script} from "forge-std/Script.sol";
import {WETH} from "../src/WETH/Weth.sol";
import "forge-std/console.sol"; 


contract DeployWeth is Script {
    function run() external returns (DeployWeth) {

        vm.startBroadcast();

        WETH weth = new WETH();
        console.log("WETH deployed at:", address(weth));

        vm.stopBroadcast();
    }
}