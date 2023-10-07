pragma circom 2.1.2;

include "./lib/poseidon.circom";
include "./lib/bitify.circom";
include "./lib/comparators.circom";

template PositionSwitcher() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}


// Verifies that merkle path is correct for a given merkle root and leaf
// pathIndices input is an array of 0/1 selectors telling whether given 
// pathElement is on the left or right side of merkle path
template VerifyMerklePath(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    component selectors[levels];
    component hashers[levels];

    signal computedPath[levels];

    for (var i = 0; i < levels; i++) {
        selectors[i] = PositionSwitcher();
        selectors[i].in[0] <== i == 0 ? leaf : computedPath[i - 1];
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        hashers[i] = Poseidon(2);
        hashers[i].inputs[0] <== selectors[i].out[0];
        hashers[i].inputs[1] <== selectors[i].out[1];
        computedPath[i] <== hashers[i].out;
    }

    root === computedPath[levels - 1];
}

// secretKey is the commitment
// secretVal is the value in KV Merkle tree
template CalculateMerkleLeaf() {
    signal input secretKey;
    signal input secretVal;

    signal output out;

    component poseidon = Poseidon(2);

    poseidon.inputs[0] <== secretKey;
    poseidon.inputs[1] <== secretVal;

    out <== poseidon.out;
}

template DARC(MFHeight, MTHeight) {
  // Private inputs
  signal input key;
  signal input val;
  signal input MTPathElements[MTHeight];
  signal input MTPathIndices[MTHeight];
  signal input MTRoot;
  signal input MFPathElements[MFHeight];
  signal input MFPathIndices[MFHeight];

  // Public inputs
  signal input MFRoot;
  signal input GroupId;

  // Verification that the source account is part of an accounts tree
  // Recreating the leaf which is the hash of an account identifier and an account value
  component accountLeafConstructor = Poseidon(2);
  accountLeafConstructor.inputs[0] <== key;
  accountLeafConstructor.inputs[1] <== val;

  // This tree is an Accounts Merkle Tree which is constituted by accounts
  // leaf = Hash(key, val) 
  // verify the merkle path
  component MTsPathVerifier = VerifyMerklePath(MTHeight);
  MTsPathVerifier.leaf <== accountLeafConstructor.out;  
  MTsPathVerifier.root <== MTRoot;
  for (var i = 0; i < MTHeight; i++) {
    MTsPathVerifier.pathElements[i] <== MTPathElements[i];
    MTsPathVerifier.pathIndices[i] <== MTPathIndices[i];
  }

  // Verification that MT is part of MF
  // Recreating the Merkle leaf
  component MTLeaf = Poseidon(2);
  MTLeaf.inputs[0] <== MTRoot;
  MTLeaf.inputs[1] <== GroupId; 

  // leaf = Hash(MTRoot, GroupId)
  // verify the merkle path
  component MFPathVerifier = VerifyMerklePath(MFHeight);
  MFPathVerifier.leaf <== MTLeaf.out; 
  MFPathVerifier.root <== MFRoot;
  for (var i = 0; i < MFHeight; i++) {
    MFPathVerifier.pathElements[i] <== MFPathElements[i];
    MFPathVerifier.pathIndices[i] <== MFPathIndices[i];
  }

}

component main {public [MFRoot, GroupId]} = DARC(20,20);