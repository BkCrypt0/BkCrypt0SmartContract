const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

const main = async () => {
    const KYC = await ethers.getContractFactory("KYC");
    const kyc = await upgrades.deployProxy(KYC,
        [
            process.env.Lib_AddressManager,
            32
        ]);
    await kyc.deployed();
    console.log("KYC dedployed at: ", kyc.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


