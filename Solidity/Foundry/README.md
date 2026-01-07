
# Commands
`forge init` -> `forge init --no-commit-` = to init a forge project
`forge build` -> `forge compile` = build/compile the project
`forge test -vvvv` = increase the verbosity level of the output. (useful for deep debugging and understanding exactly what’s happening under the hood.)
`forge test  --gas-report` = I can test with gas report statistic 
`forge fmt` = Format code

## Anvil
- Is used to Deploy a smart contract locally, since i am not in Remix i need to deploy it locally!
- It creates a local endpoint with fake available accounts and wallet, and private keys

# Deploy smart contract
- forge create SimpleStorage --interactive --broadcast => and with this interactive i will need to pass privatekey from anvil private keys
- If i have script written `forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL(from .env) --broadcast --private-key $PRIVATE_KEY(from .env)`
- Go to [DeploySimpleStorage.s.sol](https://github.com/LimeChain/Emil-Roydev-Onboarding/blob/main/Solidity/Foundry/fundamentals/foundry-simple-storage/script/DeploySimpleStorage.s.sol) for example

# Remappings
- Foundry automatically looks for the `remappings.txt` file in the root of your project directory.
    - The `remappings.txt` file is essential for resolving imports when using libraries installed via npm or forge install.
    - If you don't have a remappings.txt file, Foundry will not know how to resolve imports like @openzeppelin/.
  
# Interact with Smart contract using CLI `cast`
- Send a transaction using instruction
    - `cast send <contract_address_here> "store(uint256)" 123 --rpc-url $RPC_URL --private-key $PRIVATE_KEY`
                 /contract_address = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    
- Read from a blockchain
    - `cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "retrieve()"` 
  
# Testing Guide
## General Testing Guide
  - To make a test that expects to fail naming convention is `test_Revert....` and in the test code write `vm.expectRevert()` which expects NEXT CALL to REVERT!!!
  - `vm.prank(address(1));` => Simulate address(1) as the caller for the NEXT CALL ONLY == msg.sender = address(1)
  - `vm.startPrank(address(1));` => If i want to prank multiple calls i sandwitch them between start and stop `vm.stopPrank();`
  - Check test/Error.t.sol => to see how test_Revert works with `custom thrown errors`.

### - Event Testing Guide
  - Check [Event.t.sol](https://github.com/LimeChain/Emil-Roydev-Onboarding/blob/main/Solidity/Foundry/fundamentals/foundry-simple-storage/test/Event.t.sol) => to see practical example
  - `vm.expectEmit(true, true, false, true);` we specify which parameters from the event to check
  - `emit Transfer(...)` -> Declare the same event as declared in the contract and emit it in the test with the params
  - `e.transfer(...)` -> Call the contract function that will emit and event and this will be compared with test emitted event.
  
### - Time Testing Guide
  - `vm.warp()` - set block.timestamp to future timestamp => `vm.warp(block.timestamp + 1 days + 20 hours)`
  - `skip()` - increment current timestamp => `skip(10)`
  - `rewind()` - decrement current timestamp => `rewind(20)`
  - Check [Time.t.sol](https://github.com/LimeChain/Emil-Roydev-Onboarding/blob/main/Solidity/Foundry/fundamentals/foundry-simple-storage/test/Time.t.sol) => for example
  
### - Send Eth Testing Guide
  - `deal(address, uint)` - set a balance of an address in testing
  - `hoax(address, uint)` - Combines `deal(...)` and `vm.prank(address(...))`, Sets up a prank and set a balance
  - Example: `hoax(address(1), 456)`, `_send(456);` which uses .call{value: amount}("") to send to recieve() in the contract we are testing
  - Check [Wallet.t.sol](https://github.com/LimeChain/Emil-Roydev-Onboarding/blob/main/Solidity/Foundry/fundamentals/foundry-simple-storage/test/Wallet.t.sol) => for example
  
### - Signature Testing Guide
  - The idea is that i produce messageHash(keccak256) and sign it `vm.sign(privateKey, messageHash)` which returns (v, r ,s)
  - Then i can use `ecrecover(messageHash, v, r, s)` to recover the signer from parameters to use it for verify the signature
  - For example check test/Sign.t.sol
  - For practical real world scenario [GasLessTokenTransfer.t.sol](https://github.com/LimeChain/Emil-Roydev-Onboarding/blob/main/Solidity/Foundry/fundamentals/foundry-simple-storage/test/GaslessTokenTransfer.t.sol)
  
# Utils
### forge-std/console.sol
- Forge have console.log() functionality
- `import "forge-std/console.sol";` and then `console.log("HERE", count);`
- with `forge test -vv` i can see the logs using testing.
- You can see the code in console.sol there are many methods to call console like `console.logInt(x)` to call ints and many more!

### Casts
- `cast --to-base 0x714c2 dec` = to check some hexadecimal what value it has in the terminal
