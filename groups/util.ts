import { BigNumber } from "@ethersproject/bignumber"
import { randomBytes } from "@ethersproject/random"
import { poseidon2 } from "poseidon-lite/poseidon2"

/**
 * Generates a random big number.
 * @param numberOfBytes The number of bytes of the number.
 * @returns The generated random number.
 */
export function genRandomNumber(numberOfBytes = 31): bigint {
    return BigNumber.from(randomBytes(numberOfBytes)).toBigInt()
}

/**
 * Generates the identity commitment from (k,v) pair
 * @param k The identity key
 * @param v The identity value.
 * @returns identity commitment
 */
// export function generateCommitment(k: bigint, v: bigint): bigint {
//     return poseidon1([poseidon2([k, v])])
// }

/**
 * Generates the identity commitment from (k,v) pair
 * @param k The identity key
 * @param v The identity value.
 * @returns identity commitment
 */
export function generateCommitment(k: bigint, v: bigint): bigint {
    return poseidon2([k, v])
}
