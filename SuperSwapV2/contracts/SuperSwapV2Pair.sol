// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./SuperSwapErrors.sol";
import "./libraries/UQ112x112.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SuperSwapV2Pair is ERC20, ReentrancyGuard {
    using UQ112x112 for uint224;

    event ReservesUpdate(uint256 indexed ReserveX, uint256 indexed ReserveY);
    event LiquidityIn(address indexed liquidator, uint256 indexed tokenMinted, uint256 indexed amountX, uint256 amountY);
    event LiquidityOut(address indexed liquidator, uint256 indexed tokenBurnt, uint256 indexed amountX, uint256 amountY);
    event TokenSwap(address indexed Swapper, uint256 indexed amountXout, uint256 indexed amountYout);

    uint112 public reserveX;
    uint112 public reserveY;
    uint32 public blockTimestampLast;

    uint256 public priceXCumulativeLast;
    uint256 public priceYCumulativeLast;

    IERC20 public tokenX;
    IERC20 public tokenY;

    uint256 public constant MINIMUM_LIQUIDITY = 1000; 

    constructor() ERC20("SuperSwap", "SUPER"){}

    function initialize(address tokenA, address tokenB) public {
        if(tokenX != IERC20(address(0)) || tokenY != IERC20(address(0))) revert TokensAlreadyInitialized();

        tokenX = IERC20(tokenA);
        tokenY = IERC20(tokenB);
    }

    function mint(address to) public returns(uint256) {
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

        return liquidity;
    }

    function burn(address to) public nonReentrant returns(uint256, uint256) {
        uint256 balanceX = tokenX.balanceOf(address(this));
        uint256 balanceY = tokenY.balanceOf(address(this));

        uint256 liquidity = balanceOf(to);

        if(liquidity <= 0) revert ZeroLiqidityProvided();
        
        uint256 amountX = (liquidity * balanceX) / totalSupply();
        uint256 amountY = (liquidity * balanceY) / totalSupply();

        _burn(address(this), liquidity);

        tokenX.transfer(to, amountX);
        tokenY.transfer(to, amountY);

        balanceX = tokenX.balanceOf(address(this));
        balanceY = tokenY.balanceOf(address(this));

        update(balanceX, balanceY);

        emit LiquidityOut(to, liquidity, amountX, amountY);

        return (amountX, amountY);
    }
    
    function swap(address to, uint256 amountXOut, uint256 amountYOut) public nonReentrant {

        if(amountXOut == 0) revert InsufficientOutputAmount();
        if(amountYOut == 0) revert InsufficientOutputAmount();

        if(amountXOut > reserveX) revert InsufficientLiqidity();
        if(amountYOut > reserveY) revert InsufficientLiqidity();

        uint256 balanceX = tokenX.balanceOf(address(this)) - amountXOut;
        uint256 balanceY = tokenY.balanceOf(address(this)) - amountYOut;

        if(balanceX * balanceY < reserveX * reserveY) revert RequirementsNotMet(); 

        update(balanceX, balanceY);

        if(amountXOut > 0){
            tokenX.transfer(to, amountXOut);
        }
        if(amountYOut >0){
            tokenY.transfer(to, amountYOut);
        }

        emit TokenSwap(to, amountXOut, amountYOut);
    }

    function update(uint256 _balanceX, uint256 _balanceY) private {

        unchecked {
            uint32 timeElapsed = uint32(block.timestamp) - blockTimestampLast;

            if (timeElapsed > 0 && reserveX > 0 && reserveY > 0) {
                priceXCumulativeLast +=
                    uint256(UQ112x112.encode(reserveX).uqdiv(reserveX)) *
                    timeElapsed;
                priceYCumulativeLast +=
                    uint256(UQ112x112.encode(reserveX).uqdiv(reserveY)) *
                    timeElapsed;
            }
        }

        reserveX = uint112(_balanceX);
        reserveY = uint112(_balanceY);
        blockTimestampLast = uint32(block.timestamp);

        emit ReservesUpdate(reserveX, reserveY);
    }

    function getReserves() public view returns(uint256 reserve_X, uint256 reserve_Y, uint256 balance_X, uint256 balance_Y){
        reserve_X = reserveX;
        reserve_Y = reserveY;
        balance_X = tokenX.balanceOf(address(this));
        balance_Y = tokenY.balanceOf(address(this));

        return (reserve_X, reserve_Y, balance_X, balance_Y);
    }

}