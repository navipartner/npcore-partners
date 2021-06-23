import { CustomDragonglassError } from "dragonglass-core";

/**
 * Represents an error thrown by dragonglass-popup subsystem when encountering an invalid popup usage situation
 *
 * @export
 * @class PopupRuntimeError
 * @extends {CustomDragonglassError}
 */
export class PopupRuntimeError extends CustomDragonglassError {
    constructor(message) {
        super(message || "Invalid number or date format encountered.");
    }
};
