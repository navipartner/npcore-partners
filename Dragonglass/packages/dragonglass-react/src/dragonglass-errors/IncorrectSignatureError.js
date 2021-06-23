import { CustomDragonglassError } from "dragonglass-core";

export class IncorrectSignatureError extends CustomDragonglassError {
    /**
     * Thrown by methods when an incorrect signature is present.
     * @param {String} name Method or function name
     * @param {String} signature Expected signature
     */
    constructor(name, signature) {
        super(`Correct signature for "${name}" is (${signature})`);
    }
}