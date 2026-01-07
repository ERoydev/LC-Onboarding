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
