import { generateCommitment, genRandomNumber } from "./util"

export default class Identity {
    private _val: bigint
    private _key: bigint
    private _commitment: bigint

    /**
     * Initializes the class attributes based on the strategy passed as parameter.
     * @param identityOrMessage Additional data needed to create identity for given strategy.
     */
    constructor(k:bigint, v:bigint) {
        this._val = k
        this._key = v
        this._commitment = generateCommitment(k, v)
    }

    /**
     * Returns the identity val.
     * @returns The identity val.
     */
    public get val(): bigint {
        return this._val
    }

    /**
     * Returns the identity val.
     * @returns The identity val.
     */
    public getval(): bigint {
        return this._val
    }

    /**
     * Returns the identity key.
     * @returns The identity key.
     */
    public get key(): bigint {
        return this._key
    }

    /**
     * Returns the identity key.
     * @returns The identity key.
     */
    public getkey(): bigint {
        return this._key
    }

    /**
     * Returns the identity commitment.
     * @returns The identity commitment.
     */
    public get commitment(): bigint {
        return this._commitment
    }

    /**
     * Returns the identity commitment.
     * @returns The identity commitment.
     */
    public getCommitment(): bigint {
        return this._commitment
    }

    /**
     * Returns a JSON string with val and key. It can be used
     * to export the identity and reuse it later.
     * @returns The string representation of the identity.
     */
    public toString(): string {
        return JSON.stringify([`0x${this._val.toString(16)}`, `0x${this._key.toString(16)}`])
    }
}