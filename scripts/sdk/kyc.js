exports.updateRootRevoke = exports.verifyProof = void 0;
const { rdOwnerKYC } = require("./rdOwner");
require("dotenv").config();


const updateRootClaim = async (optionName, pi_a, pi_b, pi_c, input, currentRoot) => {
    const rdOwner = await rdOwnerKYC();
    const addRoot = await rdOwner.updateRootClaim(optionName, pi_a, pi_b, pi_c, input, currentRoot, {gasLimit: BigInt(1e7)});
    await addRoot.wait();
    console.log(1, await rdOwner.getLastRootClaim());
};
exports.updateRootClaim = updateRootClaim;

const updateRootRevoke = async (optionName, pi_a, pi_b, pi_c, input, currentRoot) => {
    const rdOwner = await rdOwnerKYC();
    const addRoot = await rdOwner.updateRootRevoke(optionName, pi_a, pi_b, pi_c, input, currentRoot, {gasLimit: BigInt(1e7)});
    await addRoot.wait();
    console.log(1, await rdOwner.getLastRootRevoke());
};
exports.updateRootRevoke = updateRootRevoke;

const verifyProof = async (proofInputJson) => {
    const rdOwner = await rdOwnerKYC();
    
    const status = await rdOwner.verifyProof(
        proofInputJson.optionName,
        proofInputJson.pi_a,
        proofInputJson.pi_b,
        proofInputJson.pi_c,
        proofInputJson.input,
        { gasLimit: BigInt(1e7) }
    )
    return status;
}
exports.verifyProof = verifyProof;

