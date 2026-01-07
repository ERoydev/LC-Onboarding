/*
    memory => Temporary, exists only during function call:
        - Cheaper
        - Function-level only
        - Gone after function ends
        - For temporary variables or copies

    -------------------------------------------------
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