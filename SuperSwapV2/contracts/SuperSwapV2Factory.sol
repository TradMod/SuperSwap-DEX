// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./SuperSwapV2Pair.sol";
import "./SuperSwapErrors.sol";
import "./interfaces/ISuperSwapV2Pair.sol";

contract SuperSwapV2Factory {

    event PairCreated(address tokenX, address tokenB, address Pair, uint256 pairNum);

    mapping (address => mapping(address => address)) public pairs;
    address[] public allPairs;

    constructor() {}

    function createPair(address tokenA, address tokenB) public returns(address pair) {
        if(tokenA == address(0) && tokenB == address(0)) revert ZeroAddress();
        if(tokenA == tokenB) revert SameAddresses();

        (address tokenX, address tokenY) = (tokenA < tokenB) ? (tokenA, tokenB) : (tokenB, tokenA);
        if(tokenX == address(0)) revert ZeroAddress();
        if(pairs[tokenX][tokenB] != address(0)) revert PairsAlreadyExists();

        bytes memory bytecode = type(SuperSwapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tokenX,tokenY));

        assembly {
            pair := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        ISuperSwapV2Pair(pair).initialize(tokenX, tokenY);
        
        pairs[tokenX][tokenY] = pair;
        pairs[tokenY][tokenX] = pair;
        allPairs.push(pair);

        emit PairCreated(tokenX, tokenY, pair, allPairs.length);
    }

    function getPair(address tokenA, address tokenB) public view returns(address pair){
        return pairs[tokenA][tokenB];
    }

}