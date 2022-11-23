// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SuperSwap is ERC20 {

    IERC20 public PKR;

    constructor(address addressPKR) ERC20("Super Swap", "SUPER"){
        PKR = IERC20(addressPKR);
    }

    function addLiquidity(uint256 amountPKR) public payable {
        PKR.transferFrom(msg.sender, address(this), amountPKR);
    }

    function swapETHtoPKR() public payable {
        require(msg.value > 0, "Not enough ETH sent");
        uint256 amountPKR = getPKR(msg.value);
        PKR.transfer(msg.sender, amountPKR);
    }

    function swapPKRtoETH(uint256 amountPKR) public {
        require(amountPKR > 0, "Not enough PKR sent");
        PKR.transferFrom(msg.sender, address(this), amountPKR);
        uint256 amountETH = getETH(amountPKR);
        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require(success);
    }

    function getAmount(uint256 inputAmount, uint256 reserveX, uint256 reserveY) public pure returns(uint256 outputAmount) {
        return (reserveY * inputAmount) / (reserveX + inputAmount);
    }

    function getETH(uint256 inputAmountPKR) public view returns(uint256 outputAmountETH) {
        uint256 rPKR = reservePKR();
        return getAmount(inputAmountPKR, address(this).balance, rPKR);
    }

    function getPKR(uint256 inputAmountETH) public view returns(uint256 outputAmountPKR) {
        uint256 rPKR = reservePKR();
        return getAmount(inputAmountETH, rPKR, address(this).balance);
    }

    function reservePKR() public view returns(uint256){
        return PKR.balanceOf(address(this));
    }

    function reserveETH() public view returns(uint256){
        return address(this).balance;
    }

}