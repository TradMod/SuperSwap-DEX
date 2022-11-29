// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./SuperSwapErrors.sol";
import "./libraries/SuperSwapV2Library.sol";
import "./interfaces/ISuperSwapV2Factory.sol";
import "./interfaces/ISuperSwapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SuperSwapV2Router {

    ISuperSwapV2Factory public immutable superSwapFactory;
    
    constructor(address factoryAddress) {
        superSwapFactory = ISuperSwapV2Factory(factoryAddress);
    }

    function addLiquidity(
        address tokenA,
        address tokenB, 
        uint256 amountAdesired, 
        uint256 amountBdesired,
        uint256 amountAmin,
        uint256 amountBmin,
        address to,
        uint256 time
        ) public returns(uint256 liquidity, uint256 amountA, uint256 amountB){
        if(superSwapFactory.getPair(tokenA, tokenB) == address(0)){
            superSwapFactory.createPair(tokenA, tokenB);   
        }
        address pairAddress = SuperSwapV2Library.pairFor(address(superSwapFactory), tokenA, tokenB);
        (amountA, amountB) = calculateAmount(tokenA, tokenB, amountAdesired, amountBdesired, amountAmin, amountBmin);
        IERC20(tokenA).transferFrom(to, pairAddress, amountA);
        IERC20(tokenB).transferFrom(to, pairAddress, amountB);

        time = block.timestamp;
        liquidity = ISuperSwapV2Pair(pairAddress).mint(to);

        return (liquidity, amountA, amountB);

    }

    function calculateAmount(
        address tokenA,
        address tokenB, 
        uint256 amountAdesired, 
        uint256 amountBdesired,
        uint256 amountAmin,
        uint256 amountBmin
        ) internal view returns(uint256 amountA, uint256 amountB){
        (uint256 reserveA, uint256 reserveB) = SuperSwapV2Library.getReserves(address(superSwapFactory), tokenA, tokenB);
        if(reserveA == 0 && reserveB == 0){
            (amountA, amountB) = (amountAdesired, amountBdesired);
        } else {
            uint256 optimalAmountB = SuperSwapV2Library.quote(amountAdesired, reserveA, reserveB);
            if(optimalAmountB <= amountBdesired){
                if(optimalAmountB < amountBmin) revert InsufficientAmount();
                (amountA, amountB) = (amountAdesired, optimalAmountB);
            } else {
            uint256 optimalAmountA = SuperSwapV2Library.quote(amountBdesired, reserveB, reserveA);
            if(optimalAmountA <= amountAdesired){
                if(optimalAmountA < amountAmin) revert InsufficientAmount();
                (amountA, amountB) = (optimalAmountA, amountBdesired);
            }
            }
        }
    }
}