
const fs = require("fs");
const { verifyProof, addIdentity } = require("../scripts/sdk/kyc");
const { setLib_AddressManager } = require("../scripts/sdk/libAddressManager");
require("dotenv").config();

/**
 * Check root claim and revoke before verify
 */
const main = async () => {
    const path = "test/example_inputs/age/";

    const addVerifierAge = await setLib_AddressManager("VERIFIER_AGE", process.env.VERIFIER_AGE); 
    console.log("Verifier age: ", addVerifierAge);
    const proofInputJson = JSON.parse(fs.readFileSync(path + "inputProof.json").toString());
    console.log(proofInputJson)
    console.log(await verifyProof(proofInputJson));
}

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
