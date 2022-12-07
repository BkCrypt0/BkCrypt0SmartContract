
const fs = require("fs");
const { verifyProof } = require("../scripts/sdk/kyc");
const { setLib_AddressManager } = require("../scripts/sdk/libAddressManager");
require("dotenv").config();

/**
 * Check root claim and revoke before verify
 */
const main = async () => {
    const path = "test/example_inputs/place/";

    const addVerifierPlace = await setLib_AddressManager("VERIFIER_PLACE", process.env.VERIFIER_PLACE);
    console.log(addVerifierPlace);
    const proofInputPlaceJson = JSON.parse(fs.readFileSync(path + "inputProof.json").toString());
    console.log(await verifyProof(proofInputPlaceJson));
}

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
