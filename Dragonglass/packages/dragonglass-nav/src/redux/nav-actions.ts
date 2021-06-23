import { createAction, createActionWithPayload } from "dragonglass-redux";
import { DRAGONGLASS_NAV_EVENTS_QUEUE_UPDATE, DRAGONGLASS_NAV_EVENTS_START, DRAGONGLASS_NAV_EVENTS_END, DRAGONGLASS_NAV_EVENTS_CLEAR } from "./nav-action-types";
import { NAVEventInfo } from "./interfaces/NAVEventInfo";

export const updateNavEventQueue = createActionWithPayload<any[]>(DRAGONGLASS_NAV_EVENTS_QUEUE_UPDATE);
export const startNavEvent = createActionWithPayload<NAVEventInfo>(DRAGONGLASS_NAV_EVENTS_START);
export const endNavEvent = createActionWithPayload<NAVEventInfo>(DRAGONGLASS_NAV_EVENTS_END);
export const clearNavEvents = createAction(DRAGONGLASS_NAV_EVENTS_CLEAR);
