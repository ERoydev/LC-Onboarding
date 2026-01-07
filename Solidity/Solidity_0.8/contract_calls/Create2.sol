// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract DeployWithCreate2 {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
}

// The other way of deploying the contract instead of using just new its the Create2 method

contract Create2Factory {
    event Deploy(address addr);

    function deploy(uint _salt) external {
        DeployWithCreate2 _contract = new DeployWithCreate2{
            salt: bytes32(_salt) // we specify salt (random number of our choice) determines the address of the contract
        }(msg.sender);
        emit Deploy(address(_contract));
    }


    // THESE TWO ARE FROM SOLIDITY BY EXAMPLE CODE
    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode) // The bytecode of the contract to be deployed
            )
        );

        return address(uint160(uint(hash))); 
    }

    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(DeployWithCreate2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}