// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "forge-std/Test.sol";
import "forge-std/console.sol";

/*
How to Sign a message in Foundry test, by callind vm.sign() and then verify signer
THIS IS AN EXAMPLE CODE HOW IT HAPPENS
*/

contract SignTest is Test {
    // private key = 123
    // public key = vm.add(private key)
    // message = "secret message"
    // message hash = keccak256(message)
    // vm.sign(private key, message hash)

    function testSignature() public {
        uint256 privateKey = 123;
        address pubKey = vm.addr(privateKey);

        bytes32 messageHash = keccak256("secret message");

        // vm.sign() sing the signature
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash); // Signature returns 3 parameters used to recover the signer

        // Then verify the signature using `ecrecover`
        address signer = ecrecover(messageHash, v, r, s); // Built-in function to recover the signer with these parameters

        assertEq(signer, pubKey);

        bytes32 invalidMessageHash = keccak256("Invalid message");
        signer = ecrecover(invalidMessageHash, v, r, s);

        assertTrue(signer != pubKey);
    }
}
