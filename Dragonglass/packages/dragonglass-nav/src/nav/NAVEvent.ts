import { INAVEventDescriptor } from "./INAVEventDescriptor";
import { INAVEventPayloadReducer } from "./INAVEventPayloadReducer";
import { INAVEventAfterInvokeCallback } from "./INAVEventAfterInvokeCallback";
import { INAVEventPayload } from "./INAVEventPayload";
import { StateStore } from "dragonglass-redux";
import { EventCoordinator } from "./EventCoordinator";
import { Debug } from "dragonglass-core";
import { NAVInvoker } from "./NAVInvoker";

export class NAVEvent implements NAVInvoker<INAVEventPayload> {
    private _payloadReducers: INAVEventPayloadReducer[];
    private _afterInvokeCallbacks: INAVEventAfterInvokeCallback[];
    private _coordinator: EventCoordinator;
    private _debug: Debug;
    public _forceAsync: boolean;

    public name: string;
    public skipIfBusy: boolean | undefined;
    public rejectDuplicate: boolean | undefined;

    constructor(eventInfo: INAVEventDescriptor | string, coordinator: EventCoordinator, stateStore: StateStore, debug: Debug) {
        const event = typeof eventInfo === "string"
            ? { name: eventInfo } as INAVEventDescriptor
            : eventInfo;

        this.name = event.name;
        this.skipIfBusy = !!event.skipIfBusy;
        this.rejectDuplicate = !!event.rejectDuplicate;
        this._forceAsync = !!event.forceAsync;
        this._coordinator = coordinator;
        this._debug = debug;

        this._payloadReducers = [];
        this._afterInvokeCallbacks = [];

        if (event.appendDataStates)
            this.registerBeforeInvokePayloadReducer((payload: any) => stateStore.appendDataStatesToTarget(payload), "appendDataStates");
    }

    /**
     * Registers a pre-invoke payload pre-processor handler function to be called before the event is sent
     * to NAV by the EventCoordinator.
     * Each registered reducer function will receive the payload that will be sent to NAV, and has a chance
     * to pre-process the payload by applying some pre-processing logic to it.
     * Each registered reducer function must be a pure function. It will receive the payload as originally
     * sent by the event invoker, or as the previous reducer function returned.
     * 
     * @param {Function} handler Handler function to be invoked before Event is invoked (sent to NAV).
     * @param {String} name Name of the handler function, for logging purposes.
     */
    registerBeforeInvokePayloadReducer(handler: Function, name: string): void {
        if (typeof handler !== "function")
            return;
        this._payloadReducers.push({ handler, name });
    }

    /**
     * Registers a post-invoke callback to be called after the Event has been fully processed by NAV.
     * 
     * @param {Function} callback Callback to be invoked after Event is processed by NAV.
     * @param {String} name Name of the callback function, for logging purposes.
     */
    registerAfterInvokeCallbacks(callback: Function, name: string): void {
        if (typeof callback !== "function")
            return;

        this._afterInvokeCallbacks.push({ callback, name });
    }

    /**
     * Executed by the EventCoordinator just before sending the event invocation to NAV. It allows individual
     * Event instances to register functions that pre-process the NAV payload before it is sent to NAV.
     * This function should be called only by the EventCoordinator.
     */
    preProcessPayloadBeforeInvoke(payload: INAVEventPayload): INAVEventPayload {
        return this._payloadReducers.reduce(
            (currentPayload, info) => {
                const newPayload = info.handler.call(this, currentPayload);
                this._debug?.info(`[Event._preProcessPayloadBeforeInvoke] ${this.name}.${info.name}: ${JSON.stringify(currentPayload)} => ${JSON.stringify(newPayload)}}`);
                return newPayload;
            },
            payload);
    }

    /**
     * Executed by the EventCoordinator after the event has been fully processed by NAV.
     * This function should be called only by the EventCoordinator.
     * 
     * @param {Object} payload Payload that was sent to NAV
     */
    postInvokeCallback(payload: INAVEventPayload): void {
        this._afterInvokeCallbacks.forEach(info => {
            this._debug?.info(`[Event._postInvokeCallback] ${this.name}.${info.name}`);
            info.callback(payload);
        });
    }

    getLogName(): string {
        return this.name;
    }

    /**
     * Raises an event in NAV.
     * The function will schedule the event execution in the EventCoordinator, and the EventCoordinator will
     * then send this event to NAV as soon as it is idle, in FIFO manner.
     * 
     * @param {Object} payload Payload to be sent to NAV
     */
    async raise(payload?: INAVEventPayload): Promise<string> {
        if (this._forceAsync) {
            return new Promise<string>(fulfill => {
                setTimeout(async () => {
                    fulfill(await this._coordinator.scheduleEvent(this, payload));
                });
            });
        } else {
            return await this._coordinator.scheduleEvent(this, payload);
        }
    }
}
