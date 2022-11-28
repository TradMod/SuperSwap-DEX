// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface ISuperSwapV2Pair {

    function mint(address) external;   

    function burn(address) external;

    function initialize(address, address) external;

    function swap(address, uint256, uint256) external;

    function getReserves() external view returns(uint256, uint256, uint256, uint256);
    
}