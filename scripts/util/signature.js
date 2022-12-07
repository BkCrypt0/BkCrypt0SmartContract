const { ethers } = require("hardhat");
const { owner } = require("../sdk/rdOwner");
require("dotenv").config();

const genSignature = async (
  proofAge
) => {
  let msg = Buffer.from(
    ethers.utils
      .solidityKeccak256(
        ["uint[2]", "uint[2][2]", "uint[2]", "uint256"],
        [proofAge.a, proofAge.b, proofAge.c, proofAge.deadline]
      )
      .substring(2),
    "hex"
  );
  return await owner.signMessage(msg);
};
module.exports = {
  genSignature,
};
