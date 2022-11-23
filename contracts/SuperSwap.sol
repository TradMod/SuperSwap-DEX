// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

    /**
     * @author ABDul Rehman
     * @title  SuperSwap V1
    */
contract SuperSwap is ERC20 {

    IERC20 public PKR;

    uint256 public constant SWAP_FEE = 1;

    constructor(address addressPKR) ERC20("Super Swap", "SUPER"){
        PKR = IERC20(addressPKR);
    }

    /**
     * @notice rPKR = PKR reserves
     * @notice rETH = ETH reserves
    */
    function addLiquidity(uint256 amountPKR) public payable {
        if(reservePKR() == 0){
            PKR.transferFrom(msg.sender, address(this), amountPKR);
            uint256 LPtokens = address(this).balance;
            _mint(msg.sender, LPtokens);
        } else {
            uint256 rPKR = reservePKR();
            uint256 rETH = address(this).balance - msg.value;
            uint256 amount_PKR = (msg.value * rPKR) / rETH;
            require(amountPKR >= amount_PKR, "not enough PKR sent");
            PKR.transferFrom(msg.sender, address(this), amount_PKR);
            uint256 LPtokens = (totalSupply() * msg.value) / rETH;
            _mint(msg.sender, LPtokens);
        }
    }

    function removeLiquidity(uint256 amount) public  {
        require(amount > 0, "invalid amount");
        uint256 ethAmount = (address(this).balance * amount) / totalSupply();
        uint256 tokenAmount = (reservePKR() * amount) / totalSupply();
        _burn(msg.sender, amount);
        (bool pass, ) = payable(msg.sender).call{value: ethAmount}("");
        require(pass);
        PKR.transfer(msg.sender, tokenAmount);
    }

    function swapETHtoPKR() public payable {
        require(msg.value > 0, "Not enough ETH sent");
        uint256 rPKR = reservePKR();
        uint256 rETH = address(this).balance - msg.value;
        uint256 amountPKR = getAmount(msg.value, rETH, rPKR);
        PKR.transfer(msg.sender, amountPKR);
    }

    function swapPKRtoETH(uint256 amountPKR) public {
        require(amountPKR > 0, "Not enough PKR sent");
        PKR.transferFrom(msg.sender, address(this), amountPKR);
        uint256 rPKR = reservePKR();
        uint256 amountETH = getAmount(amountPKR, rPKR, address(this).balance);
        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require(success);
    }

    function getAmount(uint256 inputAmount, uint256 reserveX, uint256 reserveY) public pure returns(uint256 outputAmount) {
        uint256 withFee = 100 - SWAP_FEE; 
        uint256 inputAmountWithFee = inputAmount * withFee;
        uint256 numerator = (reserveY * inputAmountWithFee);
        uint256 denominator = (reserveX + inputAmountWithFee);
        return numerator / denominator;
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