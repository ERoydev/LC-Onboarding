// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
calling parent functions
- direct
- super
   E
 /   \
F     G
 \   /
   H

*/

contract E {
    event Log(string message);
    BaseUser[] public users;

    enum UserTypes {
        Admin,
        Moderator,
        Vip,
        User
    }

    struct BaseUser {
        string name;
        uint age;
        UserTypes userType;
    }

    function createUser(string calldata _name, uint _age) external virtual {
        BaseUser memory user = BaseUser(_name, _age, UserTypes.Admin);
        users.push(user);
        emit Log("Success the user is created");
    }

    function getUserInfo(uint idx) external view returns(string memory, uint, UserTypes) {
        BaseUser memory user = users[idx];

        return (user.name, user.age, user.userType);
    }
}

contract F is E {
    function createUser(string calldata _name, uint _age) external override virtual {
        BaseUser memory user = BaseUser(_name, _age, UserTypes.Moderator);
        users.push(user);
        emit Log("Success the user is created");
    }
}

contract G is E {
    function createUser(string calldata _name, uint _age) public override virtual {
        BaseUser memory user = BaseUser(_name, _age, UserTypes.Vip);
        users.push(user);
        emit Log("Success the user is created");
    }
}

contract H is F, G {
    function createUser(string calldata _name, uint _age) public override(F, G) {
        super.createUser(_name, _age);
    }
}
