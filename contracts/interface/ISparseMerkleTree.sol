// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ISparseMerkleTree {
    /**
     * @dev Hash poseidon for 2 elements
     * @param inputs Poseidon input array of 2 elements
     * @return Poseidon hash
     */
    function hash2Elements(uint256[2] memory inputs)
        external
        view
        returns (uint256);

    /**
     * @dev Hash poseidon for 3 elements
     * @param inputs Poseidon input array of 3 elements
     * @return Poseidon hash
     */
    function hash3Elements(uint256[3] memory inputs)
        external
        view
        returns (uint256);

    /**
     * @dev Hash poseidon for 4 elements
     * @param inputs Poseidon input array of 4 elements
     * @return Poseidon hash
     */
    function hash4Elements(uint256[4] memory inputs)
        external
        view
        returns (uint256);

    /**
     * @dev Hash poseidon for sparse merkle tree nodes
     * @param left Input element array
     * @param right Input element array
     * @return Poseidon hash
     */
    function hashNode(uint256 left, uint256 right)
        external
        view
        returns (uint256);

    /**
     * @dev Hash poseidon for sparse merkle tree final nodes
     * @param key Input element array
     * @param value Input element array
     * @return Poseidon hash1
     */
    function hashFinalNode(uint256 key, uint256 value)
        external
        view
        returns (uint256);

    /**
     * @dev Verify sparse merkle tree proof
     * @param root Root to verify
     * @param siblings Siblings necessary to compute the merkle proof
     * @param key Key to verify
     * @param value Value to verify
     * @return True if verification is correct, false otherwise
     */
    function smtVerifier(
        uint256 root,
        uint256[] memory siblings,
        uint256 key,
        uint256 value
    ) external view returns (bool);
}
