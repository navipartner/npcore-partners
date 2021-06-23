import { CustomDragonglassError } from "./CustomDragonglassError";

export class InvalidOperationError extends CustomDragonglassError {
    constructor(message: string = "") {
        super(message || "Program has attempted to perform an operation that's invalid for its current state.");
    }
}