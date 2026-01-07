// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract S {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract T {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

// 2 ways to call parent constructors


// If i know the parameters that need to be passed when i write the code i can just pass them like that
contract U is S("s"), T("t") { // Initializing the parent constructors

}

// Other way to initialize the parent constructors when i dont know
contract V is S, T {
    constructor(string memory _name, string memory _text) S(_name) T(_text) {

    }
}

// I can use those in a combination
contract VV is S("s"), T { // Static 
    constructor(string memory _text) T(_text) { // Dynamic

    }
}


// Order of execution
// 1. S
// 2. T
// 3. V0
contract V0 is S, T { // Static 
    constructor(string memory _name, string memory _text) S(_name) T(_text) {}
}