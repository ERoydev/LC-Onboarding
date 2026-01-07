// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Solidity 0.8 lecture

import "forge-std/Test.sol";
import "../src/GasLessTokenTransfer/GasLesTokenTransfer.sol";
import "../src/GasLessTokenTransfer/ERC20Permit.sol";


contract GasLessTokenTransferTest is Test {
    ERC20Permit private token;
    GasLessTokenTransfer private gasless;

    uint256 constant SENDER_PRIVATE_KEY = 123;
    address sender;
    address receiver;
    uint constant AMOUNT = 1000;
    uint constant FEE = 10;

    function setUp() public {
        sender = vm.addr(SENDER_PRIVATE_KEY);
        receiver = address(2);

        token = new ERC20Permit("test", "test", 18);
        token.mint(sender, AMOUNT + FEE);

        gasless = new GasLessTokenTransfer();
    }

    function testValidSig() public {
        uint deadline = block.timestamp + 60;

        // Prepare permit message
        bytes32 permitHash = _getPermitHash(
            sender, 
            address(gasless), 
            AMOUNT + FEE, 
            token.nonces(sender),
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            SENDER_PRIVATE_KEY, permitHash
        );
        // Execute send
        gasless.send(
            address(token),
            sender,
            receiver,
            AMOUNT,
            FEE,
            deadline,
            v, r, s
        );
 
        // Check token balances
        assertEq(token.balanceOf(sender), 0, "sender balance");
        assertEq(token.balanceOf(receiver), AMOUNT, "receiver balance");
        assertEq(token.balanceOf(address(this)), FEE, "fee");
    }

    function _getPermitHash(
        address owner,
        address spender,
        uint value, 
        uint nonce,
        uint deadline
    ) private view returns (bytes32) {
        return 
            // I copied this from the ERC20Permit.sol code from the permit function
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            nonce,
                            deadline
                        )
                    )
                )
            ); 
    }
}