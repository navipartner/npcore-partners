import { IDebugSeverity } from "../interfaces/IDebugSeverity";

const getSeverity = (tag: string, ordinal: number): IDebugSeverity => ({
    _ordinal: ordinal,
    _severity: tag
});

/**
 * Defines the severity of the debug message.
 */
export const DEBUG_SEVERITY = {
    /** Indicates a verbose debugging info message */
    VERBOSE: getSeverity("VERBOSE", 0),

    /** Indicates a regular info message */
    INFO: getSeverity("INFO", 1),

    /** Indicates a log message */
    LOG: getSeverity("LOG", 2),

    /** Indicates a warning message */
    WARNING: getSeverity("WARNING", 3),

    /** Indicates a non-critical error. This error is shown as full-screen green error, but allows clicking and continuing */
    ERROR: getSeverity("ERROR", 4),

    /** Indicates a critical error. This error is shown as full-screen red error, and does not allow continuing, the session is effectively dead */
    CRITICAL: getSeverity("CRITICAL", 5)
};

// TODO: Verify that this retains line numbers, as it should according to https://stackoverflow.com/questions/13815640/a-proper-wrapper-for-console-log-with-correct-line-number)
// TODO: alternatively, use loglevel (https://www.npmjs.com/package/loglevel)
export class Debug {
    private _source: string;
    private _level: IDebugSeverity;
    private _info: Function;
    private _log: Function;
    private _warn: Function;
    private _trace: Function;
    private _error: Function;

    constructor(source: string, level: IDebugSeverity = DEBUG_SEVERITY.LOG) {
        this._source = source;
        this._level = level;

        this._log = console.log.bind(console);
        this._info = console.info.bind(console);
        this._warn = console.warn.bind(console);
        this._trace = console.trace.bind(console);
        this._error = console.error.bind(console);
    }

    get source(): string {
        return this._source;
    }

    verbose(message: string) {
        if (this._level._ordinal > DEBUG_SEVERITY.VERBOSE._ordinal)
            return;

        this._info(`[${this._source}].[${DEBUG_SEVERITY.VERBOSE._severity}] ${message}`);
    }

    info(message: string) {
        if (this._level._ordinal > DEBUG_SEVERITY.INFO._ordinal)
            return;

        this._info(`[${this._source}].[${DEBUG_SEVERITY.INFO._severity}] ${message}`);
    }

    log(message: string): void {
        if (this._level._ordinal > DEBUG_SEVERITY.LOG._ordinal)
            return;

        this._log(`[${this._source}].[${DEBUG_SEVERITY.LOG._severity}] ${message}`);
    }

    warn(message: string): void {
        if (this._level._ordinal > DEBUG_SEVERITY.WARNING._ordinal)
            return;

        this._warn(`[${this._source}].[${DEBUG_SEVERITY.WARNING._severity}] ${message}`);
    }

    trace(): void {
        this._trace();
    }

    error(message: string): void {
        if (this._level._ordinal > DEBUG_SEVERITY.ERROR._ordinal)
            return;

        this._error(`[${this._source}].[${DEBUG_SEVERITY.ERROR._severity}] ${message}`);
    }

    critical(message: string): void {
        this._error(`[${this._source}].[${DEBUG_SEVERITY.CRITICAL._severity}] ${message}`);
    }

    bug(reason: string, severity = DEBUG_SEVERITY.ERROR): void {
        let func: Function = this._info;

        switch (severity) {
            case DEBUG_SEVERITY.WARNING:
                // TODO: show a toast warning message
                func = this._warn;
                break;

            case DEBUG_SEVERITY.ERROR:
                // TODO: show a full-screen green don't panic mesage
                func = this._error;
                break;

            case DEBUG_SEVERITY.CRITICAL:
                // TODO: show a full-screen red do panic message
                func = this._error;
                break;

            default:
                return;
        }
        func(`${reason}. Check the console trace.`);
        this._trace();
    }
}
