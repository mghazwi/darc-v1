# set circuit and input
circuit='darc'
input='darc-input'
potFile='powersOfTau28_hez_final_14'

# set up proof
time circom "./$circuit".circom --r1cs --wasm
cd ./"$circuit"_js
time snarkjs groth16 setup "../$circuit".r1cs "../../potFiles/$potFile".ptau "$circuit"_0000.zkey
time snarkjs zkey contribute "$circuit"_0000.zkey "$circuit"_0001.zkey --name="1st Contributor Name" -e="e"

snarkjs zkey export verificationkey "$circuit"_0001.zkey verification_key.json
# contract
snarkjs zkey export solidityverifier "$circuit"_0001.zkey verifier.sol

# generate proof
time node generate_witness.js "$circuit".wasm "../input/$input".json witness.wtns
time snarkjs groth16 prove "$circuit"_0001.zkey witness.wtns proof.json public.json

snarkjs zkey export soliditycalldata public.json proof.json

# verify proof
snarkjs groth16 verify verification_key.json public.json proof.json
