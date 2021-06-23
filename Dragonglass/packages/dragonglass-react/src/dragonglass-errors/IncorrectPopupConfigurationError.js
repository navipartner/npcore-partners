import { CustomDragonglassError } from "dragonglass-core";

export class IncorrectPopupConfigurationError extends CustomDragonglassError {
    /**
     * Thrown by popup coordinator (or a dependent component) when a popup invoked in a workflow script is incorrectly configured.
     * @param {String} type Popup type that caused the error.
     * @param {String} description Detailed description of the reason for the invalid configuration.
     */
    constructor(type, description) {
        const details = Array.isArray(description)
            ? description.reduce((prev, current) => `${prev}\n${current}`, "")
            : ` ${description}`;
        super(`Popup "${type}" is not correctly configured. Error details:${details}`);
    }
}