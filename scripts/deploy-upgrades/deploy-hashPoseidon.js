const { ethers, upgrades } = require("hardhat");
const { poseidonContract } = require('circomlibjs');
const { owner } = require("../sdk/rdOwner");

async function main() {
    const nInputs = 6;

    let factory;
    let contract;

    for (let i = 2; i <= nInputs; i++) {
        factory = new ethers.ContractFactory(
            poseidonContract.generateABI(i),
            poseidonContract.createCode(i),
            owner,
            // {gasLimit: BigInt(1e7)}
        );
        contract = await factory.deploy();
        await contract.deployed();
        console.log(`Poseidon${i} deploy successed`, contract.address);
    }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});