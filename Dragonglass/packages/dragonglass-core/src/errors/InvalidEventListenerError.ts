import { CustomDragonglassError } from "./CustomDragonglassError";

/**
 * Represents an error thrown by EventDispatcher when attempting to subscribe to an event by passing invalid arguments (an event identifier that's
 * not been declared as supported, or passing a non-function argument as listener).
 */
export class InvalidEventListenerError extends CustomDragonglassError {
    eventName: string;

    constructor(event: string) {
        super(`Attempting to register an event listener for an unsupported event ${event}`);

        this.eventName = event;
    }
}
