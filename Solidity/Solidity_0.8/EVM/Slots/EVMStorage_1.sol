// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


// Yul syntax
// EVM storage
contract YulIntro {
    // Yul - language used for inline assembly in Solidity
    // Yul variable assignment
    // Yul types (everything is bytes32) 
    function test_yul_var() public pure returns (uint256) {
        uint256 s = 0;

        assembly {
            let x := 1 // define
            x := 2 // assign
            s := 5
        }

        return s;
    }

    // Yul types (everything is bytes32)
    function test_yul_types() public pure returns (bool x, uint256 y, bytes32 z) {
        assembly {
            x := 1 // inside assembly this will be handled as bytes32
            y := 0xaaa // inside assembly this will be handled as bytes32
            z := "Hello yul" // inside assembly this will be handled as bytes32
        }
    }
}

contract EVMStorageSingleSlot {
    // EVM storage
    // 2**256 slots, each slot can store up to 32bytes
    // Slots are assigned in the order the state variables are declared
    // Data < 32 bytes are packed into a slot (right to left)
    // sstore(k, v) = store v to slot k
    // sload(k) = load 32 bytes from slot k

    // Single variable stored in one slot

    // slot 0
    uint256 public s_x;
    // slot 1
    uint256 public s_y;
    // slot 2
    bytes32 public s_z;

    function test_sstore() public {
        // s_x = 111; => same as sstore(0, 111) -> (slot, value)
        assembly {
            sstore(0, 111)
            sstore(1, 222)
            sstore(2, 0xabababa)
        }
    }

    function test_sstore_again() public {
        // The other way to set a variable on a slot instead of counting i can use on a State Variable this:
        // s_x.slot -> store the value where the State Variable slot is using.
        assembly {
            sstore(s_x.slot, 123)
            sstore(s_y.slot, 456)
            sstore(s_z.slot, 0xcdcdcd)
        }
    }

    function test_sload() public view returns (uint256 x, uint256 y, bytes32 z) {
        assembly {
            x := sload(0) // I get the value assigned to these slot numbers
            y := sload(1)
            z := sload(2)
        }
    }

    function test_sload_again() public view returns (uint256 x, uint256 y, bytes32 z) {
        assembly {
            x := sload(s_x.slot) // I get the value assigned to these slot numbers
            y := sload(s_y.slot)
            z := sload(s_z.slot)
        }
    }
}

