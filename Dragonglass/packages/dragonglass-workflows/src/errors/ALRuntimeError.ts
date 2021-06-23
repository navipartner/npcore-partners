import { ALError } from "./ALError";
import { ErrorReporter } from "dragonglass-core";

export class ALRuntimeError extends ALError {
    private _errorReporter: ErrorReporter;

    constructor(message: string, silent: boolean, errorReporter: ErrorReporter) {
        super(`An unhandled runtime error occurred in AL: ${message}`);

        this.ALError.originalMessage = message;
        this.ALError.silent = silent;
        this._errorReporter = errorReporter;
    }

    toString(): string {
        return `[${this.name}] ${this.ALError.originalMessage || "[Empty message (pure rollback)]"}`;
    }

    /**
     * Shows the AL popup error through Dragonglass Popup object. If the error has already been shown, exits without showing
     * the error message again.
     */
    async showALError() {
        if (this.ALError.popupShown)
            return;

        if (this.ALError.originalMessage)
            await this._errorReporter.error(this.ALError.originalMessage);
        this.ALError.popupShown = true;
    }
};
