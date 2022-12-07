
exports.getProofAge = exports.getProofAge = void 0;
const { ethers } = require("hardhat");
const fs = require("fs");
const { genSignature } = require("./signature");
require("dotenv").config();

// const abiCoder = ethers.utils.defaultAbiCoder;
function numToHex(num) {
    return ethers.utils.hexZeroPad(ethers.BigNumber.from(num).toHexString(), 32);
}

const getProofAge = async (pathInput, pathProof) => {
    const inputAgeJson = JSON.parse(fs.readFileSync(pathInput).toString());
    const proofAgeJson = JSON.parse(fs.readFileSync(pathProof).toString());
    const proofAgeData = {
        a: proofAgeJson.pi_a.slice(0, 2).map(e => numToHex(e)),
        b: proofAgeJson.pi_b.slice(0, 2).map(e => e.reverse().map(e1 => numToHex(e1))),
        c: proofAgeJson.pi_c.slice(0, 2).map(e => numToHex(e))
    };

    const inputProof = {
        optionName: "VERIFIER_AGE",
        pi_a: proofAgeData.a,
        pi_b: proofAgeData.b,
        pi_c: proofAgeData.c,
        input: inputAgeJson.map(e => '0x' + BigInt(e).toString("16"))
    };
    return inputProof;
}
exports.getProofAge = getProofAge;

const getProofPlace = async (pathInput, pathProof) => {
    const inputPlaceJson = JSON.parse(fs.readFileSync(pathInput).toString());
    const proofPlaceJson = JSON.parse(fs.readFileSync(pathProof).toString());
    const proofPlaceData = {
        a: proofPlaceJson.pi_a.slice(0, 2).map(e => numToHex(e)),
        b: proofPlaceJson.pi_b.slice(0, 2).map(e => e.reverse().map(e1 => numToHex(e1))),
        c: proofPlaceJson.pi_c.slice(0, 2).map(e => numToHex(e)),
    };

    const inputProof = {
        optionName: "VERIFIER_PLACE",
        pi_a: proofPlaceData.a,
        pi_b: proofPlaceData.b,
        pi_c: proofPlaceData.c,
        input: inputPlaceJson.map(e => '0x' + BigInt(e).toString("16"))
    };
    return inputProof;
}
exports.getProofPlace = getProofPlace;

const getProofClaim = async (pathInput, pathProof) => {
    const inputClaimJson = JSON.parse(fs.readFileSync(pathInput).toString());
    const proofClaimJson = JSON.parse(fs.readFileSync(pathProof).toString());

    const inputProof = {
        pi_a: proofClaimJson.pi_a.slice(0, 2).map(e => numToHex(e)),
        pi_b: proofClaimJson.pi_b.slice(0, 2).map(e => e.reverse().map(e1 => numToHex(e1))),
        pi_c: proofClaimJson.pi_c.slice(0, 2).map(e => numToHex(e)),
        input: inputClaimJson.map(e => '0x' + BigInt(e).toString("16"))
    };
    return inputProof;
}
exports.getProofClaim = getProofClaim;

const getProofRevoke = async (pathInput, pathProof) => {
    const inputRevokeJson = JSON.parse(fs.readFileSync(pathInput).toString());
    const proofRevokeJson = JSON.parse(fs.readFileSync(pathProof).toString());

    const inputProof = {
        pi_a: proofRevokeJson.pi_a.slice(0, 2).map(e => numToHex(e)),
        pi_b: proofRevokeJson.pi_b.slice(0, 2).map(e => e.reverse().map(e1 => numToHex(e1))),
        pi_c: proofRevokeJson.pi_c.slice(0, 2).map(e => numToHex(e)),
        input: inputRevokeJson.map(e => '0x' + BigInt(e).toString("16"))
    };
    return inputProof;
}
exports.getProofRevoke = getProofRevoke;