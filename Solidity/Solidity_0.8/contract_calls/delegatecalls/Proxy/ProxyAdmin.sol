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
    uint public count; // This will be not updated when using `delegatecall`

    function inc() external {
        count += 1;
    }
}

contract CounterV2 {
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

contract Proxy {
    // This gives me Safe Storage Isolation -> Avoids collisions with other variables in the proxy or implementation. => (MANUALLY DEFINED STORAGE POINTER LOCATION called `slot`)
    bytes32 public constant IMPLEMENTATION_SLOT = bytes32(
        uint(keccak256("eip1967.proxy.implementation")) - 1
        // `-1` is added to randomize the hash otherwise i know the string -> -1 creates hard-to-collide storage locations.
    );
    bytes32 public constant ADMIN_SLOT = bytes32( // => (MANUALLY DEFINED STORAGE POINTER LOCATION called `slot`)
        uint(keccak256("eip1967.proxy.admin")) - 1
        // `-1` is added to randomize the hash otherwise i know the string -> -1 creates hard-to-collide storage locations.
    );
    
    constructor() {
        _setAdmin(msg.sender);
    }

    modifier ifAdmin() {
        require(msg.sender == _getAdmin(), "not admin");
        _;
    }

    function changeAdmin(address _admin) external ifAdmin {
        _setAdmin(_admin);
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == _getAdmin(), "not authorized");
        _setImplementation(_implementation);
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
        _delegate(_getImplementationSlot());
    }


    receive() external payable { 
        _delegate(_getImplementationSlot());
    }
    // ========================================================================
    // Functions to GET and WRITE the values stored on the SLOT's

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _getImplementationSlot() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }
    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = zero address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation not a contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }
    // ========================================================================

    function admin() external ifAdmin view returns (address) {
        return _getAdmin();
    }

    function implementation() external ifAdmin view returns (address) {
        return _getImplementationSlot();
    }
}

// ======================================================================== PROXY ADMIN ADDED
contract ProxyAdmin{
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function getProxyAdmin(address proxy) external view returns (address) {
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.admin, ())); // fn and inputs () because no inputs for this fn
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function getProxyImplementation(address proxy) external view returns (address) {
        (bool ok, bytes memory res) = proxy.staticcall(abi.encodeCall(Proxy.implementation, ())); // fn and inputs () because no inputs for this fn
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function changeProxyAdmin(address payable proxy, address _admin) external onlyOwner {
        Proxy(proxy).changeAdmin(_admin);
    }

    function upgrade(address payable proxy, address implementation) external onlyOwner {
        Proxy(proxy).upgradeTo(implementation);
    }
}

// ======================================================================== EXAMPLE OF HOW IT SHOULD BE IMPLEMENTED
// The library providing function to interact with my storage easily
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    // function to get the pointer of the storage
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    } 
}

// THIS IS FOR EXAMPLE MY PROXY WHERE I NEED TO CREATE A SLOT POINTER AND THE FUNCTION TO GET AND WRITE THIS SLOT USING THE LIBRARY
contract TestSlot {
    bytes32 public constant SLOT = keccak256("TEST_SLOT"); // I manually define this as Storage Location, it is a fixed pointer to where i will persist data in the contract storage

    // Get the pointer of where this slot is storred
    function getSlot() external view returns (address) {
        return StorageSlot.getAddressSlot(SLOT).value; // This will return the pointer of where we store AddressSlot struct and i take the `.value`
    }

    // Write to this Slot
    function writeSlot(address _addr) external {
        StorageSlot.getAddressSlot(SLOT).value = _addr;
    }
}
