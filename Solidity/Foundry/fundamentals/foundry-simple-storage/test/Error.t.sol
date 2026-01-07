
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "forge-std/Test.sol";
import {Error} from "../src/Error/Error.sol";


contract ErrorTest is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }

    function test_RevertThrowError() public {
        vm.expectRevert(bytes("not authorized"));
        err.throwError();
    }

    function test_RevertThrowCustomError() public {
        vm.expectRevert(Error.NotAuthorized.selector); // I pass the selector from the contract to revert this error
        err.throwCustomError();
    }

    function testErrorLabel() public { // Putting assertion labels
        assertEq(uint256(1), uint256(1), "test 1");
        assertEq(uint256(1), uint256(1), "test 2");
        assertEq(uint256(1), uint256(1), "test 3");
        assertEq(uint256(1), uint256(1), "test 4");
    }
}