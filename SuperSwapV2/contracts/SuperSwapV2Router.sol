// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./SuperSwapErrors.sol";
import "./interfaces/ISuperSwapV2Factory.sol";

contract SuperSwapV2Router {

    ISuperSwapV2Factory public immutable superSwapFactory;
    
    constructor(address factoryAddress) {
        superSwapFactory = ISuperSwapV2Factory(factoryAddress);
    }
    
}