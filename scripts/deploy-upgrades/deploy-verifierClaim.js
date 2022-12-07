const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

const deployVerifierClaim = async (option) => {
    let Verifier = await ethers.getContractFactory(`VerifierClaim${option}`);
    let verifier = await upgrades.deployProxy(Verifier, []);
    await verifier.deployed();
    console.log(`Verifier Claim ${option} dedployed at: `, verifier.address);
}

const main = async () => {
    await deployVerifierClaim(3);
    await deployVerifierClaim(10);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


