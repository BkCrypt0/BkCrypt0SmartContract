const fs = require("fs");
const { getProofClaim } = require("../scripts/util/getProof");

const main = async () => {
    const path = "test/example_inputs/claim/";
    const inputProof = await getProofClaim(path + "public.json", path + "proof.json", 60 * 60 * 24);

    const json = JSON.stringify(inputProof, null, 2);

    fs.writeFile(path + "inputProof.json", json, (err) => {
        if (err) {
            console.log(err);
        } else {
            console.log("write successful: " + path + "inputProof.json");
        }
    });

    console.log("inputProof:", inputProof);
}

main()
    .then(() => { })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
