// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "./IERC20.sol";

// AMM is a market that lets users trade two tokens, and your formula decides the exchange price based on current pool balances.

// THIS APPROACH IS NOT EXACTLY CONSTANT SUM INSTEAD I HAVE USED UNISWAP
// CS => x + y = k, i use x * y = k

/*
Formula for the price will be the Uniswap V2:
    - x * y = k

x = 100 (Token A in the pool)
y = 10 (Token B in the pool)
k = Constant (the product of the reserves, which should remain constant)

k = x * y = 100 * 10 = 1000(constant).

If User A wants to swap 10 Token A for Token B
    - Now the amount of Token A in the pool will be x_new = 100 + 10 = 110
    - Calculate the new amount of Token B in the pool:
        - We know that x_new * y_new = k:
        - So we know also that 110(x_new) * y_new = 5000
        - y_new = 5000 / 110 = 45.45 -> New amount of token B in the pool
    
    - To calculate how much User A of Token B in exchange for their 10 Token A, we subtract the new amount of Token B in the pool(y_new) from the origin amount Token B (y)
        - User A gets => 50 - 45.45 = 4.55

    Summary:
        - When the Token B is smaller than Token A, logically we get smaller amount of Token B compared to token amount we gave from Token A
*/


contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0; // Store the balance of token0
    uint public reserve1; // Store the balance of token1

    uint public totalSupply; // Total shares
    mapping(address => uint) public balanceOf; // Keep shares for each user
    uint public k;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    // Mint and burn here are responsible for the Shares when user provide for Liquidity or remove his provided Liquidity
    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint res0, uint res1) private {
        reserve0 = res0;
        reserve1 = res1;
    }

    function swap(address _tokenIn, uint _amountIn) external returns (uint amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token");

        uint _k = reserve0 * reserve1;
        uint x; // amount In -> holds the total reserve
        uint y; // amount Out -> holds the total reserve

        // Define these so i can skip multiple if statements this is huge optimization because before refactor had multiple if else's that was identical.
        bool isToken0 = _tokenIn == address(token1);
        (IERC20 tokenIn, IERC20 tokenOut, uint resIn, uint resOut) = isToken0 ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        // 1. transfer token in and set `x, y` variables.z
        x = tokenIn.balanceOf(address(this));
        y = tokenOut.balanceOf(address(this));
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // 2. calculate amount out (including fees) using Uniswap V2 formula x * y = k
        uint x_new = x + _amountIn;
        uint y_new = _k / x_new;

        uint _amountOut = ((y - y_new) * 997) / 1000; // This will be received for the amountIn provided + 0.3% fee 

        // 3. update reserve0 and reserve1
        (uint res0, uint res1) = isToken0 ? (resIn + _amountIn, resOut - amountOut) : (resOut - _amountOut, resIn + _amountIn);
        _update(res0, res1);

        // 4. transfer token out
        tokenOut.transferFrom(address(this), msg.sender, _amountOut);
    }

    function addLiquidity(uint _amount0, uint _amount1) external returns (uint) {
        // Adding liquidity means a user deposits both tokens (e.g., Token A and Token B) into the AMM pool, becoming a liquidity provider (LP).
        /*
        First liquidity add	shares = sqrt(amount0 * amount1)	Create initial share supply
        Later liquidity add	shares = min((amount0 * total) / r0, (amount1 * total) / r1)
        */

        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        uint shares;
        uint bal0 = token0.balanceOf(address(this)); // This are my new reserves balances after user has inserted the tokens
        uint bal1 = token1.balanceOf(address(this));

        // calculation for shares
        if (totalSupply == 0) {
            shares = _amount0 + _amount1;
        } else {
            shares = ((_amount0 + _amount1) * totalSupply) / (reserve0 + reserve1);
        }
        require(shares > 0, "shares = 0");

        // mint shares for user and update the reserves
        _mint(msg.sender, shares);
        _update(bal0, bal1);
        return shares;
    }

    function removeLiquidity(uint _shares) external returns (uint t0, uint t1) {
        t0 = (reserve0 * _shares) / totalSupply;
        t1 = (reserve1 * _shares) / totalSupply;

        _burn(msg.sender, _shares);
        _update(reserve0 - t0, reserve1 - t1);

        if (t0 > 0) {
            token0.transfer(msg.sender, t0);
        } 
        if (t1 > 0) {
            token1.transfer(msg.sender, t1);
        }

    }

    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}