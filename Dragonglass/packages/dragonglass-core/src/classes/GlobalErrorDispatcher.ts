import { EventDispatcher } from "./EventDispatcher";

const CRITICAL_ERROR = "CRITICAL_ERROR";
const UNHANDLED_AL_ERROR = "UNHANDLED_AL_ERROR";
const SILENT_AL_ERROR = "SILENT_AL_ERROR";

export const GLOBAL_ERRORS = {
    CRITICAL_ERROR,
    UNHANDLED_AL_ERROR,
    SILENT_AL_ERROR
};

const getSerializableErrorInfo = (error: any): object => ({
    ...(
        error instanceof Error
            ? {
                message: error.message,
                stack: error.stack
            }
            : {
                message: `${error}`
            }
    ),

    date: (new Date()).toISOString()
});

class GlobalErrorDispatcher extends EventDispatcher {
    constructor() {
        super(Object.values(GLOBAL_ERRORS));
    }

    raiseUnhandledALError(error: any) {
        this.raise(UNHANDLED_AL_ERROR, error);
    }

    raiseSilentALError(error: any) {
        this.raise(SILENT_AL_ERROR, error);
    }

    raiseCriticalError(error: any) {
        this.raise(CRITICAL_ERROR, error, getSerializableErrorInfo(error));
    }
}

export default new GlobalErrorDispatcher();
