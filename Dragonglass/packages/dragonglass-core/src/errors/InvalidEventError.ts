import { CustomDragonglassError } from "./CustomDragonglassError";

/**
 * Represents an error thrown by EventDispatcher when attempting to raise an event that's not supported by the dispatcher.
 */
export class InvalidEventError extends CustomDragonglassError {
    eventName: string;

    constructor(event: string) {
        super(`Attempting to invoke an unsupported event ${event}`);

        this.eventName = event;
    }
}
