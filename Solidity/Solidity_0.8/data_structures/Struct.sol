// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/*
    memory => Temporary, exists only during function call:
        - Cheaper
        - Function-level only
        - Gone after function ends
        - For temporary variables or copies

    storage => Permanent, saved on the blockchain
        - More expensive
        - Lives as part of the contract
        - Keeps data between calls
        - For modifying or referencing state vars

    Examples:
        Car memory lambo = Car({model: "Lamborghini", year: 1920, owner: msg.sender});

        - lambo is a temporary object
        - it lives only in the function and will be deleted after the function ends.
        - Changes to it will not affect the contract's permanent state

        ----------------------------------------------
        Car storage _car = cars[0];

        cars => is a State Variable like `Car[] public cars`

        - _car is a reference to the actual object store in the contract at cars[0]
        - If you modify _car.model you're changing the real data on-chain
*/

contract Structs {
    struct Car {
        string model;
        uint year;
        address owner;
    }

    Car public car;
    Car[] public cars;
    mapping(address => Car[]) public carsByOwner;

    function examples() external {
        // To ways to initialize
        Car memory toyota = Car("Toyota", 1990, msg.sender);
        Car memory lambo = Car({model: "Lamborghini", year: 1920, owner: msg.sender});

        Car memory tesla; // It will set the default value 
        tesla.model = "Tesla";
        tesla.year = 2035;
        tesla.owner = msg.sender;

        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla);

        cars.push(Car("Ferrari", 2023, msg.sender));

        // GET
        Car storage _car = cars[0];
        _car.year = 1999; // This change will be saved to the actual object after function because of `storage` keyword

        delete _car.owner; // reset owner to the default value

        delete cars[1]; // The car struct stored here will be reseted to the default value => IT WILL NOT DISAPPEAR LIKE ORDINARY DELETE
    }
}