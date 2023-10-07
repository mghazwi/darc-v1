# DARC: Decentralized Anonymous Researcher Credentials for Access to Federated Genomic Data

This is a proof-of-concept implementation of the DARC protocol, described in the paper ["DARC: Decentralized Anonymous Researcher Credentials for Access to Federated Genomic Data"](https://st.fbk.eu/assets/areas/events/TDI2023/papers/2_2_AlghazwiMohammed.pdf).

## Dependencies  

To be able to compile and run [`Circom`](https://github.com/iden3/circom) circuits see https://docs.circom.io/getting-started/installation/.

## Usage

### off-chain Groups
Navigate to `./groups`. 

create an off-chain groups using the scripts in `./groups` by running the command:

```bash
ts-node ./Generate.ts
```

### Circuits 
Navigate to `./zkp/circuits/`.

To compile the circuits and generate the proof run the command:

```bash
bash ./runCircuit.sh
```

### Contracts
Navigate to `./contracts`

The main contract is `DARC.sol` which contains the logic to issue the credential. 

`CredRegistry.sol` is the registry for the credentials

`Groups.sol` manages the roots for the merkle forest and contains details on each group within the forest. 

`verifier/verifier.sol` is the snarks verifier contracts generated from the circuit.

