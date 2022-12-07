// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISparseMerkleTree} from "./interface/ISparseMerkleTree.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MerkleTreeWithHistory is Initializable {
    uint256 public ROOT_HISTORY_SIZE;

    uint256 public levels;
    uint256 public currentRootClaimLeaf;
    uint256 public currentRootRevokeLeaf;

    mapping(uint256 => uint256) public rootsClaim;
    mapping(uint256 => uint256) public rootsRevoke;

    /*╔══════════════════════════════╗
      ║          CONSTRUCTOR         ║
      ╚══════════════════════════════╝*/

    function __MerkleTreeWithHistory_init(uint256 _levels)
        internal
        onlyInitializing
    {
        require(_levels > 0, "_levels should be greater than zero");
        require(_levels < 40, "_levels should be less than 40");
        levels = _levels;
        ROOT_HISTORY_SIZE = 30;
        currentRootClaimLeaf = 0;
        currentRootRevokeLeaf = 0;
        rootsClaim[currentRootClaimLeaf] = 0;
        rootsRevoke[currentRootRevokeLeaf] = 0;
    }

    /*  ╔══════════════════════════════╗
      ║        ADMIN FUNCTIONS       ║
      ╚══════════════════════════════╝ */

    function _insert(uint256 _rootClaim) internal returns (bool) {
        uint256 newRootClaimLeaf = (currentRootClaimLeaf + 1) %
            ROOT_HISTORY_SIZE;
        currentRootClaimLeaf = newRootClaimLeaf;
        rootsClaim[currentRootClaimLeaf] = _rootClaim;
        return true;
    }

    function _revoke(uint256 _rootRevoke) internal returns (bool) {
        uint256 newRootRevokeLeaf = (currentRootRevokeLeaf + 1) %
            ROOT_HISTORY_SIZE;
        currentRootRevokeLeaf = newRootRevokeLeaf;
        rootsRevoke[currentRootRevokeLeaf] = _rootRevoke;
        return true;
    }

    function _setRootHistorySize(uint256 _rootHistorySize) internal {
        ROOT_HISTORY_SIZE = _rootHistorySize;
    }

    /*  ╔══════════════════════════════╗
      ║        GETTER       ║
      ╚══════════════════════════════╝ */
    /**
    @dev Whether the root is present in the root history
  */
    function isKnownRootClaim(uint256 _rootClaim) public view returns (bool) {
        if (_rootClaim == 0) {
            return false;
        }
        uint256 _currentRootClaimLeaf = currentRootClaimLeaf;
        uint256 i = _currentRootClaimLeaf;
        do {
            if (_rootClaim == rootsClaim[i]) {
                return true;
            }
            if (i == 0) {
                i = ROOT_HISTORY_SIZE;
            }
            i--;
        } while (i != _currentRootClaimLeaf);
        return false;
    }

    /**
    @dev Whether the root is present in the root history
  */
    function isKnownRootRevoke(uint256 _rootRevoke) public view returns (bool) {
        uint256 _currentRootRevokeLeaf = currentRootRevokeLeaf;
        uint256 i = _currentRootRevokeLeaf;
        do {
            if (_rootRevoke == rootsRevoke[i]) {
                return true;
            }
            if (i == 0) {
                i = ROOT_HISTORY_SIZE;
            }
            i--;
        } while (i != _currentRootRevokeLeaf);
        return false;
    }

    /**
    @dev Returns the last root claim
  */
    function getLastRootClaim() public view returns (uint256) {
        return rootsClaim[currentRootClaimLeaf];
    }

    /**
    @dev Returns the last root revoke
  */
    function getLastRootRevoke() public view returns (uint256) {
        return rootsRevoke[currentRootRevokeLeaf];
    }
}
