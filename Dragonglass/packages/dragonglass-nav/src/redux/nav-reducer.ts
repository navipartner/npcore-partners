import { NAVEventInfo } from "./interfaces/NAVEventInfo";
import { createReducer } from "dragonglass-redux";
import { initialState } from "./nav-initial-state";
import {
    DRAGONGLASS_NAV_EVENTS_QUEUE_UPDATE,
    DRAGONGLASS_NAV_EVENTS_END,
    DRAGONGLASS_NAV_EVENTS_START,
    DRAGONGLASS_NAV_EVENTS_CLEAR
} from "./nav-action-types";
import { INVOCATION_FAILED } from "./../nav/EventConstants";
import { NAVEventsState } from "./interfaces/NAVEventsState";

export const reducer = createReducer<NAVEventsState>(initialState, {
    [DRAGONGLASS_NAV_EVENTS_QUEUE_UPDATE]: (state, payload: any[]) => {
        const result = { ...state };
        result.queue = [...payload];
        return result;
    },

    [DRAGONGLASS_NAV_EVENTS_START]: (state, payload: NAVEventInfo) => {
        const result = { ...state };
        result.active = { ...state.active };
        result.active[payload.invocationId] = payload;
        return result;
    },

    [DRAGONGLASS_NAV_EVENTS_END]: (state, payload: NAVEventInfo) => {
        const result = { ...state };
        result.active = { ...state.active };
        delete result.active[payload.invocationId];
        if (payload.status === INVOCATION_FAILED)
            result.errors[payload.invocationId] = payload;
        return result;
    },

    [DRAGONGLASS_NAV_EVENTS_CLEAR]: () => {
        const result = { ...initialState };
        return result;
    }
});
