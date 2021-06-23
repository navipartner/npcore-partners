import { EventDispatcher } from "./EventDispatcher";

const TRANSACTION_START = "TRANSACTION_START";
const BUTTON_CLICK = "BUTTON_CLICK";
const FRAMEWORK_READY = "FRAMEWORK_READY";
const REFRESH_DATA = "REFRESH_DATA";
const SET_OPTIONS = "SET_OPTIONS";
const SET_VIEW = "SET_VIEW";

// TODO: These three do not belong here. Maybe we need to support later inclusion of events (later than during constructor calling)
const WORKFLOW_START = "WORKFLOW_START";
const WORKFLOW_COMPLETE = "WORKFLOW_COMPLETE";
const WORKFLOW_FAIL = "WORKFLOW_FAIL";

export const GLOBAL_EVENTS = {
    TRANSACTION_START,
    BUTTON_CLICK,
    FRAMEWORK_READY,
    REFRESH_DATA,
    SET_OPTIONS,
    SET_VIEW,
    WORKFLOW_START,
    WORKFLOW_COMPLETE,
    WORKFLOW_FAIL
};

class GlobalEventDispatcher extends EventDispatcher {
    constructor() {
        super(Object.values(GLOBAL_EVENTS));
    }

    startTransaction() {
        this.raise(TRANSACTION_START);
    }

    buttonClick(button: any) {
        this.raise(BUTTON_CLICK, button);
    }

    frameworkReady() {
        this.raise(FRAMEWORK_READY);
    }

    refreshData(data: any) {
        this.raise(REFRESH_DATA, data);
    }
}

export default new GlobalEventDispatcher();
