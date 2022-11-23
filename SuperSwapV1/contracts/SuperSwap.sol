// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

    /**
     * @author ABDul Rehman
     * @title  SuperSwap V1
    */
contract SuperSwap is ERC20 {

    IERC20 private PKR;

    constructor(address addressPKR) ERC20("SuperSwap", "SUPER"){
        PKR = IERC20(addressPKR);
    }

    function addLiquidity(uint256 amountPKR) public payable {
        PKR.transferFrom(msg.sender, address(this), amountPKR);
    }

    function swapETHtoPKR() public payable {
        require(msg.value > 0, "not enough ETH sent");
        uint256 rPKR = reservePKR();
        uint256 amountPKR = getAmount(msg.value, address(this).balance, rPKR);
        PKR.transfer(msg.sender, amountPKR);
    }

    function swapPKRtoETH(uint256 amountPKR) public {
        require(amountPKR > 0, "not enough PKR sent");
        uint256 rPKR = reservePKR();
        PKR.transferFrom(msg.sender, address(this), amountPKR);
        uint256 amountETH = getAmount(amountPKR, rPKR, address(this).balance);
        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require(success);
    }

    function getAmount(uint256 inputAmount, uint256 reserveX, uint256 reserveY) public pure returns(uint256) {
        uint256 numerator = (reserveY * inputAmount);
        uint256 denominator = (reserveX + inputAmount);
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