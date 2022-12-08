
const fs = require("fs");
const {updateRootRevoke } = require("../scripts/sdk/kyc");
const { setLib_AddressManager } = require("../scripts/sdk/libAddressManager");
require("dotenv").config();

const updateRoot = async (path) => {
    let InputAgeJson = JSON.parse(fs.readFileSync(path + "inputProof.json").toString());
    await setLib_AddressManager("VERIFIER_REVOKE", process.env.VERIFIER_REVOKE); 
    await updateRootRevoke(
        InputAgeJson.pi_a,
        InputAgeJson.pi_b,
        InputAgeJson.pi_c,
        InputAgeJson.input
    );
}
const main = async () => {
    await updateRoot("test/example_inputs/revoke/revoke3/");
    await updateRoot("test/example_inputs/unrevoke/")
}

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
