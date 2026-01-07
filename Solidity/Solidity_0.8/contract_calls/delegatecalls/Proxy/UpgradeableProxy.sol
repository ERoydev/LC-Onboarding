// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// Transparent upgradeable proxy pattern
// Topics
// - Intro (wrong way)
// - Return data from fallback
// - Storage for implementation and admin
// - Separate user / admin interfaces
// - Proxy admin
// - Demo

contract CounterV1 {
    address public implementation; // But when i put these variable that persists in the contract calling this using `delegatecall`, this will data persist.
    address public admin; // But when i put these variable that persists in the contract calling this using `delegatecall`, this will data persist.
    uint public count; // This will be not updated when using `delegatecall`

    function inc() external {
        count += 1;
    }
}

contract CounterV2 {
    address public implementation;
    address public admin;
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}


/*
.delegatecall() is a low-level function in Solidity used to execute code from another contract in the context of the calling contract.

Key Points:
Storage, msg.sender, and msg.value stay local to the calling contract.

The code from the target contract is executed, but all state changes happen in the calling contract.
*/

// delegatecall runs the implementation's code in the context of the proxy's storage,
// but msg.sender and msg.value come from the external caller (the user).

contract BuggyProxy {
    // When i use `delegatecall` from this contract it executes the code for CounterV1 but uses the storage for BuggyProxy contract
    // So thats why count in CounterV1 stays `0` even after i have incremented() it, but instead it changes the address of the implementation `adds 1 there` when i inc().
    address public implementation;
    address public admin;
    // Align all the storage data with the implementation contracts so the (0 slot will be implementation, 1 slot will be admin)

    constructor() {
        admin = msg.sender;
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");
        implementation = _implementation;
    }

    function _delegate(address _implementation) private {
        // This is from Solidity by example upgradeable proxy 
        // https://www.cyfrin.io/glossary/upgradeable-proxy-solidity-code-example
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.

            // calldatacopy(t, f, s) - copy s bytes from calldata at position f to mem at position t
            // calldatasize() - size of call data in bytes
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.

            // delegatecall(g, a, in, insize, out, outsize) -
            // - call contract at address a
            // - with input mem[in…(in+insize))
            // - providing g gas
            // - and output area mem[out…(out+outsize))
            // - returning 0 on error (eg. out of gas) and 1 on success
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            // returndatacopy(t, f, s) - copy s bytes from returndata at position f to mem at position t
            // returndatasize() - size of the last returndata
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                // revert(p, s) - end execution, revert state changes, return data mem[p…(p+s))
                revert(0, returndatasize())
            }
            default {
                // return(p, s) - end execution, return data mem[p…(p+s))
                return(0, returndatasize())
            }
        }
        // (bool ok, bytes memory res) = implementation.delegatecall(msg.data); 
        // require(ok, "delegatecall failed");  

    }

    fallback() external payable {
        _delegate(implementation);
    }


    receive() external payable { 
        _delegate(implementation);
    }
}

