// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

    /**
     * @author ABDul Rehman
     * @title  SuperSwap V1
     * @notice Uniswap V1 clone
    **/
contract SuperSwap is ERC20 {

    IERC20 public immutable PKR;

    constructor(address _addressPKR) ERC20("SuperSwap", "SUPER"){
        require(_addressPKR != address(0), "Zero Address");
        PKR = IERC20(_addressPKR);
    }

    /**
     * @notice rETH = ETH reserves
     * @notice rPKR = PKR reserves
    **/
    function addLiquidity(uint256 _amountPKR) public payable returns(uint256){
        require(_amountPKR > 0, "invalid input");
        require(msg.value > 0, "not enough ETH sent");
        if(reservePKR() == 0){
            PKR.transferFrom(msg.sender, address(this), _amountPKR);
            uint256 liquidityProvided = address(this).balance;
            _mint(msg.sender, liquidityProvided);
            return liquidityProvided;
        } else {
            uint256 rPKR = reservePKR();
            uint256 rETH = address(this).balance - msg.value;
            uint256 amountPKR = (msg.value * rPKR) / rETH;
            require(_amountPKR >= amountPKR, "not enough PKR sent");
            PKR.transferFrom(msg.sender, address(this), _amountPKR);
            uint256 liquidityProvided = (totalSupply() * msg.value) / rETH;
            _mint(msg.sender, liquidityProvided);
            return liquidityProvided;
        }
    }

    function removeLiquidity(uint256 _amount) public returns(uint256, uint256){
        require(_amount > 0, "invalid input");
        uint256 rETH = address(this).balance;
        uint256 rPKR = reservePKR();
        uint256 amountETH = (_amount * rETH) / totalSupply();
        uint256 amountPKR = (_amount * rPKR) / totalSupply();

        _burn(msg.sender, _amount);
        PKR.transfer(msg.sender, amountPKR);
        (bool pass, ) = payable(msg.sender).call{value: amountETH}("");
        require(pass);

        return (amountETH, amountPKR);
    }

    function swapETHtoPKR() public payable {
        require(msg.value > 0, "not enough ETH sent");
        uint256 rPKR = reservePKR();
        uint256 amountPKR = getAmount(msg.value, address(this).balance, rPKR);
        PKR.transfer(msg.sender, amountPKR);
    }

    function swapPKRtoETH(uint256 _amountPKR) public {
        require(_amountPKR > 0, "not enough PKR sent");
        uint256 rPKR = reservePKR();
        PKR.transferFrom(msg.sender, address(this), _amountPKR);
        uint256 amountETH = getAmount(_amountPKR, rPKR, address(this).balance);
        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require(success);
    }

    /**
     * @notice Swap-Fee: 0.5%
    **/
    function getAmount(uint256 inputAmount, uint256 reserveX, uint256 reserveY) public pure returns(uint256) {
        uint256 inputAmountWithFee = inputAmount * 995;
        uint256 numerator = (reserveY * inputAmountWithFee);
        uint256 denominator = (reserveX * 1000 + inputAmountWithFee);
        uint256 outputAmount = numerator / denominator;
        return outputAmount;
    }

    function reservePKR() public view returns(uint256){
        return PKR.balanceOf(address(this));
    }

    function reserveETH() public view returns(uint256){
        return address(this).balance;
    }

}