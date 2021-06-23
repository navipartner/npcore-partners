import { CustomDragonglassError } from "dragonglass-core";

/**
 * Represents an error thrown by FormatManager when encountering an invalid format situation
 *
 * @export
 * @class FormatError
 * @extends {CustomDragonglassError}
 */
export class FormatError extends CustomDragonglassError {
    constructor(message) {
        super(message || "Invalid number or date format encountered.");
    }
};
