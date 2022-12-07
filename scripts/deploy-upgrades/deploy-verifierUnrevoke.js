const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

const main = async () => {
    let Verifier = await ethers.getContractFactory(`VerifierUnrevoke`);
    let verifier = await upgrades.deployProxy(Verifier, []);
    await verifier.deployed();
    console.log(`Verifier Unrevoke dedployed at: `, verifier.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


