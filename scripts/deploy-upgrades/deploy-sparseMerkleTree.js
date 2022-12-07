const { ethers, upgrades } = require("hardhat");

require("dotenv").config();

async function main() {
    // console.log(poseidonContract);
    const nInputs = 6;
    let P = [];

    for (let i = 2; i <= nInputs; i++) {
        P.push(process.env[`POSEIDON${i}`])
    }
    const SparseMerkleTree = await ethers.getContractFactory("SparseMerkleTree");
    const sparseMerkleTree = await upgrades.deployProxy(SparseMerkleTree, [...P]);
    await sparseMerkleTree.deployed();

    console.log("Sparse Merkle Tree Address: ", sparseMerkleTree.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});