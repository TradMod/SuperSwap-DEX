// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./SuperSwapErrors.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

    /**
     * @author ABDul Rehman
     * @title  SuperSwap V2
     * @notice Uniswap V2 clone
    **/
contract SuperSwapV2Pair is ERC20, ReentrancyGuard {

    event ReservesUpdate(
        uint256 indexed ReserveX,
        uint256 indexed reserveY
    );

    event LiquidityIn(
        address indexed liquidator,
        uint256 indexed tokenMinted,
        uint256 indexed amountX,
        uint256 amountY
    );
    event LiquidityOut(
        address indexed liquidator,
        uint256 indexed tokenBurnt,
        uint256 indexed amountX,
        uint256 amountY
    );

    uint256 public reserveX;
    uint256 public reserveY;

    IERC20 public immutable tokenX;
    IERC20 public immutable tokenY;

    uint256 public constant MINIMUM_LIQUIDITY = 1000; 

    constructor(address _tokenX, address _tokenY) ERC20("SuperSwap", "SUPER"){
        tokenX = IERC20(_tokenX);
        tokenY = IERC20(_tokenY);
    }

    function mint(address to) public {
        uint256 balanceX = tokenX.balanceOf(address(this));
        uint256 balanceY = tokenY.balanceOf(address(this));

        uint256 amountX = balanceX - reserveX;
        uint256 amountY = balanceY - reserveY;

        uint256 liquidity;

        if(totalSupply() == 0){
            liquidity = ((amountX * amountY) / 2) - MINIMUM_LIQUIDITY;
        } else {
            liquidity = ((amountX * totalSupply()) / reserveX) - ((amountY * totalSupply()) / reserveY);
        }

        if(liquidity <= 0) revert InsufficientLiqidityProvided();

        _mint(to, liquidity);

        update(balanceX, balanceY);

        emit LiquidityIn(to, liquidity, amountX, amountY);
    }

    function burn(address to) public nonReentrant {
        uint256 balanceX = tokenX.balanceOf(address(this));
        uint256 balanceY = tokenY.balanceOf(address(this));

        uint256 liquidity = balanceOf(to);

        if(liquidity <= 0) revert ZeroLiqidityProvided();
        
        uint256 amountX = (liquidity * balanceX) / totalSupply();
        uint256 amountY = (liquidity * balanceY) / totalSupply();

        transferFrom(to, address(this), liquidity);

        _burn(address(this), liquidity);

        tokenX.transfer(to, amountX);
        tokenY.transfer(to, amountY);

        balanceX = tokenX.balanceOf(address(this));
        balanceY = tokenY.balanceOf(address(this));

        update(balanceX, balanceY);

        emit LiquidityOut(to, liquidity, amountX, amountY);
    }

    function update(uint256 _balanceX, uint256 _balanceY) internal {
        reserveX = _balanceX;
        reserveY = _balanceY;

        emit ReservesUpdate(reserveX, reserveY);
    }

}