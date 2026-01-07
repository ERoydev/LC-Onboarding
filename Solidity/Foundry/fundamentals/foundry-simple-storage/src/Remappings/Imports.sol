// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
    `forge install` is the primary way to import external libraries into your Foundry project. (Forge)
    It works similarly to package managers like npm or pip, but it uses Git to fetch and manage the libraries.
*/

// forge install rari-capital/solmate
import "solmate/tokens/ERC20.sol"; // I specify this in remappings.txt file

contract Token is ERC20("name", "symbol", 18) {}

import "@openzeppelin/contracts/access/Ownable.sol"; // OpenZeppelin ERC20; I specify the mapping to node_modules in remappings.txt

contract TestOz is Ownable(address(0)) {}

/*  
REMAPPINGS:
    - `forge install rari-capita/solmate`
    - Using `forge remappings` i can see what files i have intsalled and where they are located.
    - To Update a package, you can use `forge update lib/solmate` to fetch the latest version of the package.
    - To remove a package, you can use `forge remove solmate` to delete the package from your project.

    npm i @openzeppelin/contracts


    - Foundry automatically looks for the `remappings.txt` file in the root of your project directory.
        - The `remappings.txt` file is essential for resolving imports when using libraries installed via npm or forge install.
        - If you don't have a remappings.txt file, Foundry will not know how to resolve imports like @openzeppelin/.
*/
