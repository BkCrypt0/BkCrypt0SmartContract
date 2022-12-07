const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

const main = async () => {
    const KYC = await ethers.getContractFactory("KYC");
    console.log(
        await upgrades.upgradeProxy(
            process.env.KYC,
            KYC
        )
    );

    console.log("KYC upgraded");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


