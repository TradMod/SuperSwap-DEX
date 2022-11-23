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
        uint256 rPKR = reservePKR();
        uint256 amountPKR = (rPKR * msg.value) / (address(this).balance + msg.value);
        PKR.transfer(msg.sender, amountPKR);
    }

    function swapPKRtoETH(uint256 amountPKR) public payable {
        require(amountPKR > 0, "Not enough PKR sent");
        PKR.transferFrom(msg.sender, address(this), amountPKR);
        uint256 rPKR = reservePKR();
        uint256 amountETH = (address(this).balance * msg.value) / (rPKR + msg.value);
        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require(success);
    }

    function reservePKR() public view returns(uint256){
        return PKR.balanceOf(address(this));
    }

    function reserveETH() public view returns(uint256){
        return address(this).balance;
    }

}