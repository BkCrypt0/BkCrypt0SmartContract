const { ethers } = require("hardhat");
const { mimcSpongecontract } = require("circomlibjs");
const { owner } = require("../sdk/rdOwner");
require("dotenv").config();

const main = async () => {
    const factory = new ethers.ContractFactory(mimcSpongecontract.abi, mimcSpongecontract.createCode(0, 32), owner);
    const contract = await factory.deploy();
    await contract.deployed();
    console.log(`Deployment successful! Contract Address: ${contract.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


