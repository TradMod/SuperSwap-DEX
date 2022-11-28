// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface ISuperSwapV2Factory {

    function getPair(address, address) external view returns(address);

    function createPair(address, address) external returns(address);
    
}