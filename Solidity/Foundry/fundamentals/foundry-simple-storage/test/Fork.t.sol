// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Solidity 0.8 lecture

import "forge-std/Test.sol";
import "forge-std/console.sol";

// This is Testing using alchemy mainnet so i ran the test against the mainnet

// interface IWETH {
//     function balanceOf(address) external veiw returns (uint256);
//     function deposit() external payable;
// }

// contract ForkTest is Test {
//     IWETH public weth;

//     function setUp() public {
//         weth = IWETH(); // Address of WETH here that is deployed on the mainnet
//     }

//     function testDeposit() public {
//         uint balBefore = weth.balanceOf(address(this));
//         console.log("balance before", balBefore);

//         weth.deposit{value: 100}();

//         uint balAfter = weth.balanceOf(address(this));
//         console.log("balance after", balAfter);
//     }
// }
