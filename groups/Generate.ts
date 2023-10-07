import { Group } from "@semaphore-protocol/group"
import Identity from "./id"

// Merkle tree (Group) 
const MT = new Group(1)
const groupid = BigInt(3)
// Merkle forest
const MF = new Group(2)
// create identity H(H(k,v))
const k = BigInt(911)
const v = BigInt(5)
const identity = new Identity(k,v)
console.log("user id")
console.log(identity)
const commit = identity.getCommitment()
// add identity to MT
MT.addMember(commit)
// get MT proof 
const mtproof = MT.generateMerkleProof(0)

// get commitment for the group 
const g3 = new Identity(mtproof.root,groupid)
console.log("g2 id")
console.log(g3)
// add commitment to MF
MF.addMember(g3.getCommitment())
// get MF proof
const mfproof = MF.generateMerkleProof(0)

// print proofs
console.log("mtproof")
console.log(mtproof)
console.log("mfproof")
console.log(mfproof)
