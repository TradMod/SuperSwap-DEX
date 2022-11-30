// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface ISuperSwapV2Pair {

    function mint(address) external returns(uint256);   

    function burn(address) external returns(uint256, uint256);

    function initialize(address, address) external;

    function swap(address, uint256, uint256) external;

    function transferFrom(address, address, uint256) external returns(bool);

    function getReserves() external view returns(uint256, uint256, uint256, uint256);
    
}