// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MerkleTreeWithHistory.sol";
import "./interface/IVerifier.sol";
import "./lib/Lib_AddressResolver.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "hardhat/console.sol";

contract KYC is
    Lib_AddressResolver,
    MerkleTreeWithHistory,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    mapping(uint256 => bool) public leafsClaimTree;
    mapping(uint256 => bool) public leafsRevokeTree;
    /*╔══════════════════════════════╗
      ║            EVENTS            ║
      ╚══════════════════════════════╝*/

    event UpdateRootClaim(uint[] indexed inputs, uint256 timestamp);
    event UpdateRootRevoke(uint[] indexed inputs, uint256 timestamp);

    /*╔══════════════════════════════╗
      ║          CONSTRUCTOR         ║
      ╚══════════════════════════════╝*/

    function initialize(
        address _libAddressManager,
        uint32 _merkleTreeHeight
    ) public initializer {
        require(
            levels == 0 && address(libAddressManager) == address(0),
            "KYC already initialize"
        );

        leafsRevokeTree[0] = true;

        __Lib_AddressResolver_init(_libAddressManager);
        __MerkleTreeWithHistory_init(_merkleTreeHeight);
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
    }

    /**
     * Pause relaying.
     */
    function pause() external onlyOwner {
        _pause();
    }

    function unpauseContract() external onlyOwner {
        _unpause();
    }

    /*  ╔══════════════════════════════╗
        ║        ADMIN FUNCTIONS       ║
        ╚══════════════════════════════╝       */

    function updateRootClaim(
        string memory _optionName, //Ex: VERIFIER_CLAIM_3
        uint[2] memory pi_a,
        uint[2][2] memory pi_b,
        uint[2] memory pi_c,
        uint[] memory input,
        uint256 currentRoot
    ) external onlyOwner whenNotPaused returns (bool) {
        require(
            currentRoot == getLastRootClaim(),
            "Invalid current root claim"
        );

        _verifyProof(_optionName, pi_a, pi_b, pi_c, input);

        // for (uint256 i = 1; i < input.length; i++) {
        //     if (input[i] == 0) continue;
        //     require(!leafsClaimTree[input[i]], "leafsClaimTree is existed");
        //     leafsClaimTree[input[i]] = true;
        // }

        bool isInsert = _insert(input[0]);
        emit UpdateRootClaim(input, block.timestamp);
        return isInsert;
    }

    function updateRootRevoke(
        string memory _optionName, //Ex: VERIFIER_REVOKE_1 or VERIFIER_UNREVOKE
        uint[2] memory pi_a,
        uint[2][2] memory pi_b,
        uint[2] memory pi_c,
        uint[] memory input,
        uint256 currentRoot
    ) external onlyOwner whenNotPaused returns (bool) {
        require(
            currentRoot == getLastRootRevoke(),
            "Invalid current root revoke"
        );
        _verifyProof(_optionName, pi_a, pi_b, pi_c, input);

        bool isRevoke = _revoke(input[0]);
        emit UpdateRootRevoke(input, block.timestamp);
        return isRevoke;
    }

    function setRootHistorySize(
        uint256 _rootHistorySize
    ) public onlyOwner whenNotPaused {
        require(_rootHistorySize > 1, "rootHistorySize need greater than 1");
        _setRootHistorySize(_rootHistorySize);
    }

    /*  ╔══════════════════════════════╗
      ║        USERS FUNCTIONS       ║
      ╚══════════════════════════════╝ */

    function verifyProof(
        string memory _optionName, //Ex: VERIFIER_AGE
        uint[2] memory pi_a,
        uint[2][2] memory pi_b,
        uint[2] memory pi_c,
        uint[] memory input
    ) external view returns (bool) {
        require(
            isKnownRootRevoke(uint256(input[0])) &&
                isKnownRootClaim(uint256(input[1])),
            "Cannot find your merkle root"
        ); // Make sure to use a recent one

        require(
            block.timestamp <= input[input.length - 1],
            "Proof is expired time!"
        );
        return _verifyProof(_optionName, pi_a, pi_b, pi_c, input);
    }

    function _verifyProof(
        string memory _optionName, //Ex: VERIFIER_AGE
        uint[2] memory pi_a,
        uint[2][2] memory pi_b,
        uint[2] memory pi_c,
        uint[] memory input
    ) internal view returns (bool) {
        return
            IVerifier(resolve(_optionName)).verifyProof(
                pi_a,
                pi_b,
                pi_c,
                input
            );
    }
}
