// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../SuperSwapErrors.sol";
import "../SuperSwapV2Pair.sol";
import "../interfaces/ISuperSwapV2Pair.sol";

library SuperSwapV2Library {

    function sortTokens(address tokenA, address tokenB) internal pure  returns(address tokenX, address tokenY) {
        if(tokenA == tokenB) revert SameAddresses();
        (tokenX, tokenY) =  tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if(tokenA == address(0)) revert ZeroAddress();
        return (tokenX, tokenY);
    }

    function getReserves(address factoryAddress, address tokenA, address tokenB) internal view returns(uint256 reserveA, uint256 reserveB){
        (address tokenX, address tokenY) = sortTokens(tokenA, tokenB);
        address pairAddress = pairFor(factoryAddress, tokenX, tokenY);
        (uint256 reserveX, uint256 reserveY,,) = ISuperSwapV2Pair(pairAddress).getReserves();
        (reserveA, reserveB) = tokenA == tokenX ? (reserveX, reserveY) : (reserveY, reserveX);
        return (reserveA, reserveB);
    }

    /// computes pair-address without external calls like CREATE2
    function pairFor(address factoryAddress, address tokenA, address tokenB) internal pure returns(address pairAddress){
        (address tokenX, address tokenY) = sortTokens(tokenA, tokenB);
        bytes32 salt = keccak256(abi.encodePacked(tokenX, tokenY));
        bytes32 bytecode = keccak256(abi.encodePacked(type(SuperSwapV2Pair).creationCode));
        bytes32 pairHash = keccak256(abi.encodePacked(bytes1(0xff), factoryAddress, salt, bytecode));
        return pairAddress = address(uint160(uint256(pairHash)));
    }

    // function qoute() internal view returns() {

    // }
}