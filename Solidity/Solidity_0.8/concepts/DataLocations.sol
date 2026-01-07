// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// Data locations - storage, memory and calldata

// calldata - is like memory except it is used for function inputs. It saves gas
// For example when i pass it in another function as parameter i pass it without copying it and that saves gas by avoiding copies. While memory makes a copy to pass to a func

// When i am returning or passing reference types(like string, arrays or structs), Solidity need to know how the data should be handled
// - Its not a simple value like uint or bool.

contract DataLocations {
    struct MyStruct {
        uint foo;
        string text;
    }

    mapping(address => MyStruct) public myStructs;

    function examples(uint[] calldata y, string calldata s) external returns (uint[] memory) {
        // calldata inputs are not modifiable, we cannot change the values inside it
        // it can save gas when i pass this in another function

        myStructs[msg.sender] = MyStruct({foo: 123, text: "bar"});

        MyStruct storage myStruct = myStructs[msg.sender];
        myStruct.text = "foo";

        MyStruct memory readOnly = myStructs[msg.sender];
        readOnly.foo = 456; // This change will not be saved after function ends and this `memory` will disapear.

        _internal(y);
        // If it was memory solidity will need to copy this and pass it to another function

        uint[] memory memArr = new uint[](3); // In memory i can create only fixed sized array
        memArr[0] = 234;
        return memArr;
    }

    function _internal(uint[] calldata y) private {
        uint x = y[0];
    }
}