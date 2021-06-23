import { CustomDragonglassError } from "dragonglass-core";
import { IALError } from "../interfaces/IALError";

export class ALError extends CustomDragonglassError {
    public ALError: IALError;

    constructor(message: string) {
        super(message);

        this.ALError = {
            handled: false,
            originalMessage: null,
            popupShown: false,
            silent: false
        };
    }
    
    /**
     * Marks error as handled. A handled error may still propagate into the Workflow code execution promise rejection catch,
     * and it will still unconditionally stop the execution of any remaining workflow JavaScript code, but will not trigger any
     * additional reportCriticalError calls.
     */
    handle(): void {
        this.ALError.handled = true;
    }
}