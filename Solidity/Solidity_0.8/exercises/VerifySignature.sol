// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
Signature verification is four steps:
    1. message to sign
    2. hash(message)
    3. sign(hash(message), private key) | offchain
    4. ecrecover(hash(message), signature) == signer
*/

/*
The way i test it:
    1. I create messageHash
    2. Then i connect my metamask wallet using console `ethereum.enable()`
    3. Then i create two variables `account, hash` account is the hash of my metamask account, hash is the messageHash
    4. Then with console `etherium.request({method: "personal_sign", params: [account, hash]})` I sing the messagehash
    5. From the promise i can take the signature for this operation
    6. A take getEthSignedMessageHash and i pass the messageHash from the getMessageHash() method 
    7. Now for the recover() method i pass ethSignedMessageHash and the signature from (step 4. and step 5.) in the promise from my metamask signature
    8. Then in the Verify i use the address that recover returns, i put the raw string message and i put the signature from step 5.
*/

contract VerifySig {
    function verify(address _signer, string memory _message, bytes memory _sig) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Etherium Signed Message:\n32", // prefix used in Etherium when signing messages
            _messageHash));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
        // Need to split sig into three parts
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    // ecrecover => build-in Solidity function that lets me recover the ETH address that signed a givene message
    // Who signed the message ? => exrecover tells me.
    // Used to verify digital signatures off-chain, on-chain

    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) { // sig.length = 32 + 32 + 1 = 65
        require(_sig.length == 65, "Invalid singature length");

        assembly {
            // mloads() reads 32 bytes from some position
            r := mload(add(_sig, 32)) // with this add(_sig, 32) meaning from _sig skip 32 bytes(which are the length of the _sig because it is dynamic value)
            s := mload(add(_sig, 64)) // skip 32 + 32
            v := byte(0, mload(add(_sig, 96))) // Get the first byte from the 32 bytes after we skipped 96
        }
    }
}