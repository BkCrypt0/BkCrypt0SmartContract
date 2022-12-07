// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IPoseidon2 {
    function poseidon(uint256[2] memory inputs) external pure returns (uint256);
}

interface IPoseidon3 {
    function poseidon(uint256[3] memory inputs) external pure returns (uint256);
}

interface IPoseidon4 {
    function poseidon(uint256[4] memory inputs) external pure returns (uint256);
}

interface IPoseidon5 {
    function poseidon(uint256[5] memory inputs) external pure returns (uint256);
}

interface IPoseidon6 {
    function poseidon(uint256[6] memory inputs) external pure returns (uint256);
}
