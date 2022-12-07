# BkCrypt0-Contract

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

## Prerequire
- Node

### Clone responsitory and setup environment

```
$ git clone git@github.com:BkCrypt0/BkCrypto-Contract.git
$ cd BkCrypto-Contract
$ npm install --save-dev
```

### Config url and ENVIRONMENT_VARIABLE in .env

- Copy and update from file .env_example

## Table of contents
1. [Overview](#Overview)
2. [Architecture](#Architecture)
3. [Deploy Guide](#Deploy-Guide)
4. [Update Root](#Update-Root)
5. [Verify](#Verify)
6. [Frontend Contract](#Frontend-Contract)
## Overview

These contracts supply for users function what verify their proof.
It currently includes **age verification** and **place verification**.

## Architecture

It has 4 main contracts.

+ **Verifier**: these contracts verifier will verify proof was submit on Smart Contract. To generate verifier contracts. Please see project please see project [BKCrypt0-Circuit](https://github.com/BkCrypt0/BkCrypt0-Circuit.git)

+ **Lib_AddressManager**: this contract will store add of verifier contracts

+ **MerkleTreeWithHistory**: this is abstract contract, it will store neccessory information of Claim Tree and Revoke Tree on Smart Contract

+ **KYC**: this contract is used for verify user proof and update root tree

**Admin role**:

- Update new root claim or revoke on Smart Contract which play an important role when verify user's proof

- set address contract what is used to verify proof

- set root history size which store history of some latest proofs. Because of updating proof, so it will has case that user hold their proof with old root and submit it for third party without its updated

**User role**:

- use function was provided by admin for verifying proof

## Deploy Guide

If you use our service, please ignore these steps.

**Compile contract** before deploying.

```
hardhat compile
```

**deploy contracts** in the following order

```
npx hardhat run scripts/deploy-upgrades/deploy-libAddressManager.js
```

**save** LibAddressManager address to **.env** file. Then, continues deploying:

```
npx hardhat run scripts/deploy-upgrades/deploy-kyc.js
npx hardhat run scripts/deploy-upgrades/deploy-veriferClaim.js
npx hardhat run scripts/deploy-upgrades/deploy-veriferRevoke.js
npx hardhat run scripts/deploy-upgrades/deploy-verifierAge.js
npx hardhat run scripts/deploy-upgrades/deploy-verfierPlace.js
```

When deploying completed, **save** its address to **.env** file. Then, **set address** for address of **verifer contracts** in contract [Lib_AddressManager](https://github.com/BkCrypt0/BkCrypto-Contract/blob/main/contracts/lib/Lib_AddressManager.sol). You can see example in file [setLibAddressManager](https://github.com/BkCrypt0/BkCrypto-Contract/tree/main/scripts/sdk/examples/setLibAddressManager.js)

The other contracts is used for [BkCrypt0-Frontend](https://github.com/BkCrypt0/BkCrypt0-Frontend.git). It supply **poseidonHash** and **verifierSparseMerkleTree** function. To **deploy**, run:

```
npx hardhat run scripts/deploy-upgrades/deploy-hashPoseidon.js
npx hardhat run scripts/deploy-upgrades/deploy-sparseMerkleTree.js
```

## Update Root

- To *update* **root**. Please see example in file [testUpdateRootClaim](https://github.com/BkCrypt0/BkCrypto-Contract/tree/main/test/testUpdateRootClaim.test.js) or file [testUpdateRootRevoke](https://github.com/BkCrypt0/BkCrypto-Contract/tree/main/test/testUpdateRootRevoke.test.js)

- To *create* proof and public file for **update root**. Please see our server project [BKCrypt0-Server](https://github.com/BkCrypt0/BkCrypto-Server.git)

## Verify

Please *update* claim and/or revoke **root** if meet error **"Can't file merkle tree root"**.
**Generate** new signature if signature was **expired time**.

- To *verify* **age proof**. Please see example in file [testVerifyAge](https://github.com/BkCrypt0/BkCrypto-Contract/tree/main/test/testVerifyAge.test.js).

- To *verify* **place proof**. Please see example in file [testVerifyPlace](https://github.com/BkCrypt0/BkCrypto-Contract/tree/main/test/testVerifyPlace.test.js).

- To *create* inputProof file for **verify** age or place **proof**. Please see our server project [BKCrypt0-Server](https://github.com/BkCrypt0/BkCrypto-Server.git)

## Frontend Contract

To *use* **PoseidonHash** and **VerifierSMT** function. Please see our server project [BKCrypt0-Frontend](https://github.com/BkCrypt0/BkCrypt0-Frontend.git)
