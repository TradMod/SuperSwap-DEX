// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./SuperSwap.sol";

contract SuperFactory {
    
    mapping (address => address) private tokenToExchange;

    function createExchange(address _tokenAddress) public returns(address){
        require(_tokenAddress != address(0), "invalid token address");
        require(tokenToExchange[_tokenAddress] == address(0), "exchange already exists");

        SuperSwap superSwap = new SuperSwap(_tokenAddress);
        tokenToExchange[_tokenAddress] = address(superSwap);

        return address(superSwap);
    }

    function getExchange(address _tokenAddress) public view returns(address) {
        return tokenToExchange[_tokenAddress];
    }

}