import { CustomDragonglassError } from "dragonglass-core";

/**
 * Represents an error thrown when there are too many instances of a component that should be single-instance
 *
 * @export
 * @class TooManyInstancesError
 * @extends {CustomDragonglassError}
 */
export class TooManyInstancesError extends CustomDragonglassError {
    constructor(message) {
        super(message || "Invalid number or date format encountered.");
    }
};
