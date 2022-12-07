// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IKYC {
    function updateRootClaim(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory inputs
    ) external returns (bool);

    function updateRootRevoke(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory inputs
    ) external returns (bool);

    function verifyProof(
        string memory _optionName, //Ex: VERIFIER_AGE
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory input
    ) external view returns (bool);
}
