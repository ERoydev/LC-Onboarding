// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;


contract X {
    User[] public users;
    mapping(address => bool) public isUserInList;

    event AddedUser(string message, string name);
    event DeleteUser(string message, string name);
    
    struct User {
        address wallet;
        string name;
        uint age;
    }

    function changeUsername(address _wallet) external virtual {
        for(uint i = 0; i < users.length; i ++) {
            if (users[i].wallet == _wallet) {
                users[i].name = string(abi.encodePacked(users[i].name, "-X_contract"));
            } 
        }
    }
}

contract Y is X {
    function addUser(address _wallet, string calldata _name, uint _age) external {
        User memory user = User(_wallet, _name, _age);
        users.push(user);
        emit AddedUser("Success the user is added, Name: ", _name);
    }

    function changeUsername(address _wallet) external override virtual {
        for(uint i = 0; i < users.length; i ++) {
            if (users[i].wallet == _wallet) {
                users[i].name = string(abi.encodePacked(users[i].name, "-Y_contract"));
            } 
        }
    }
}

// This way Z inheriths Y and X at the same time
contract Z is X, Y {
    // First i have to specify the most Based and the most derived in order meaning i need to say X, Y not Y, X

    function changeUsername(address _wallet) external override(X, Y) {
        // Specify override parameters override(X, Y) or (Y, X) it doesn't matter
        for(uint i = 0; i < users.length; i ++) {
            if (users[i].wallet == _wallet) {
                users[i].name = string(abi.encodePacked(users[i].name, "-Z_contract"));
            } 
        }
    }

    function removeUser(address _wallet) external {
        for(uint i = 0; i < users.length; i ++) {
            if (users[i].wallet == _wallet) {
                delete users[i];
                emit DeleteUser("Success the user is deleted", users[i].name);
            }
        }
    }

}