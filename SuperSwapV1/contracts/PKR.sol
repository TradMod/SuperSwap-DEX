// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PKR is ERC20 {

    uint256 public supplyMinted;

    uint256 public constant MAX_SUPPLY = 50000 * 10**18;
    
    constructor(uint initialSupply) ERC20("Digital PKR", "PKR") {
        supplyMinted += initialSupply * 10**18;
        _mint(msg.sender, initialSupply * 10**18);
    }

    function mintPKR(uint256 inputAmount) public {
        require(MAX_SUPPLY > supplyMinted + inputAmount * 10**18, "All PKR minted");
        supplyMinted += inputAmount * 10**18;
        _mint(msg.sender, inputAmount * 10**18);
    }
    
}