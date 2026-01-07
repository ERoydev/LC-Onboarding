// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/*

Total cost for a given memory size is computed as follows:
    - memory_size_word = (memory_byte_size + 31) / 32
    - memory_cost = (memory_size_word ** 2) / 512 + (3 * memory_size_word)

    grows quadratic
*/

contract MemExp {
    function alloc_mem(uint256 n) external view returns (uint256) {
        uint256 gas_start = gasleft();
        uint256[] memory arr = new uint256[](n);
        uint256 gas_end = gasleft();
        return gas_start - gas_end;
    }

}