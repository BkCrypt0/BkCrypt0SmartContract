
const fs = require("fs");
const { setLib_AddressManager } = require("../libAddressManager");
require("dotenv").config();

const main = async () => {
    const verifier = [
        "VERIFIER_CLAIM_3", "VERIFIER_CLAIM_10", 
        "VERIFIER_REVOKE_3", "VERIFIER_REVOKE_10", 
        "VERIFIER_UNREVOKE"
    ]
    let setAddress;
    for (let i = 0; i < verifier.length; i++) {
        setAddress = await setLib_AddressManager(verifier[i], process.env[verifier[i]]);
        console.log(verifier[i], setAddress);
    }
}

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
