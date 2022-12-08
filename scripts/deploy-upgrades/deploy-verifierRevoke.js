const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

const deployVerifierRevoke = async (option) => {
    let Verifier = await ethers.getContractFactory(`VerifierRevoke${option}`);
    let verifier = await upgrades.deployProxy(Verifier, []);
    await verifier.deployed();
    console.log(`Verifier Revoke ${option} dedployed at: `, verifier.address);
}

const main = async () => {
    await deployVerifierRevoke(3);
    await deployVerifierRevoke(10);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


