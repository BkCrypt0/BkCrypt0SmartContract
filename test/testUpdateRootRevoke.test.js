
const fs = require("fs");
const {updateRootRevoke } = require("../scripts/sdk/kyc");
const { setLib_AddressManager } = require("../scripts/sdk/libAddressManager");
require("dotenv").config();

const main = async () => {
    const path = "test/example_inputs/revoke/";
    const InputAgeJson = JSON.parse(fs.readFileSync(path + "inputProof.json").toString());
    // console.log(InputAgeJson);
    const addVerifierRevoke = await setLib_AddressManager("VERIFIER_REVOKE", process.env.VERIFIER_REVOKE); 
    // console.log(addVerifierRevoke);

    await updateRootRevoke(
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
