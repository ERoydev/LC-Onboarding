// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// I Define Interface which allows me to call another contracts that i dont have access to the code
interface ICounter {
    function count() external view returns (uint);
    function inc() external;
}

// Imagine this is somewhere where i dont have access to this code
contract Counter {
    uint public count;
    
    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

contract CallInterface {
    uint public count;
    
    function examples(address _counter) external {
        ICounter(_counter).inc();
        count = ICounter(_counter).count();
    }
}