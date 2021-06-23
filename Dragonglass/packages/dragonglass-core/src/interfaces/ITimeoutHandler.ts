import { EventDispatcher } from "../classes/EventDispatcher";

export interface ITimeoutHandler {
    suspend(): boolean;
    resume(): boolean;
    isDialogShown(): boolean;
    isSuspended(): boolean;
    isTimeoutActive(): boolean;
    eventDispatcher: EventDispatcher;
}
