
const fs = require("fs");
const { verifyProof, updateRootClaim } = require("../scripts/sdk/kyc");
const { setLib_AddressManager } = require("../scripts/sdk/libAddressManager");
require("dotenv").config();

const main = async () => {
    const path = "test/example_inputs/claim/";
    const InputAgeJson = JSON.parse(fs.readFileSync(path + "inputProof.json").toString());
    // console.log(InputAgeJson);
    const addVerifierClaim = await setLib_AddressManager("VERIFIER_CLAIM", process.env.VERIFIER_CLAIM); 
    // console.log(addVerifierClaim);

    await updateRootClaim(
        InputAgeJson.pi_a,
        InputAgeJson.pi_b,
        InputAgeJson.pi_c,
        InputAgeJson.input
    );


    // const proofInputAgeJson = JSON.parse(fs.readFileSync(path + "inputProof3.json").toString());
    // console.log(await verifyProof(proofInputAgeJson));
}

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
