import { NAVEvent } from "./NAVEvent";
import { Debug, Ready } from "dragonglass-core";
import { EventQueue } from "./EventQueue";
import { NAVManager } from "./NAVManager";
import { IEventInfo } from "./IEventInfo";
import { InvalidOperationError } from "dragonglass-core";
import {
    INVOCATION_SUCCESSFUL,
    INVOCATION_FAILED,
    REJECT_DUPLICATE_THRESHOLD,
    SKIPPED_BUSY,
    REJECTED_DUPLICATE
} from "./EventConstants";
import { StateStore } from "dragonglass-redux";
import { endNavEvent, startNavEvent } from "../redux/nav-actions";

let isNavProcessingAnEvent = false;
let nextInvocationId = 0;

let initialized = false;
let instance: EventCoordinator;
const INSTANTIATION_TOKEN = Symbol();

export class EventCoordinator {
    private _eventQueue: EventQueue;
    private _nav: NAVManager;
    private _stateStore: StateStore;
    private _lastSource: NAVEvent | null;
    private _lastDataStringified: string | null;
    private _lastTimestamp: number;
    private _debug: Debug;

    constructor(nav: NAVManager, stateStore: StateStore, debug: Debug, instantiationToken: Symbol = Symbol()) {
        if (instantiationToken !== INSTANTIATION_TOKEN)
            throw new InvalidOperationError("An attempt was made to instantiate EventCoordinator directly. Call Ready.instance instead.");

        this._nav = nav;
        this._stateStore = stateStore;
        this._eventQueue = new EventQueue(stateStore);
        this._nav.subscribeBusyChanged(this.busyChanged.bind(this));

        this._lastSource = null;
        this._lastDataStringified = null;
        this._lastTimestamp = 0;
        this._debug = debug;
    }

    /**
     * Invokes an event in NAV.
     * It first preprocesses (reduces) the payload through registered preprocessors (reducers). Then it invokes the
     * event in NAV. When NAV invokes the invocation callback, it invokes the event post-invoke callbacks, resolves
     * the promise returned by the original event invocation (Event.raise) and then schedules processing of more
     * events from the event queue.
     * 
     * @param {Object} eventInfo Event info containing NAV Event invocation information
     * @param {Number} invocationId Unique identifier of each NAV invocation, for traceability purposes
     */
    private _invokeNAV(eventInfo: IEventInfo, invocationId: number): void {
        if (!Ready.instance.isReady) {
            Ready.instance.run(() => this._invokeNAV(eventInfo, invocationId));
            return;
        }

        const { event, payload, timestamp } = eventInfo;

        this._stateStore.dispatch(startNavEvent({
            invocationId: invocationId,
            name: event.getLogName(),
            event: event
        }));

        try {
            const args = event.preProcessPayloadBeforeInvoke(payload);
            this._debug?.log(`[InvokeExtensibilityMethod.send.${invocationId}] Event: ${event.getLogName()}, Arguments: ${JSON.stringify(payload)}`);
            isNavProcessingAnEvent = true;
            this._nav.invokeBackEnd(
                event.name,
                args,
                false,
                () => {
                    this._debug?.log(`[InvokeExtensibilityMethod.callback.${invocationId}] Event: ${event.getLogName()} completes after ${Date.now() - timestamp}ms`);
                    this._finalizeNAVInvocation(invocationId, eventInfo, INVOCATION_SUCCESSFUL);
                });
        } catch (error) {
            this._debug?.error(`[InvokeExtensibilityMethod.error.${invocationId}] Event: ${event.getLogName()}, Error: ${error}`)
            this._finalizeNAVInvocation(invocationId, eventInfo, INVOCATION_FAILED, error);
        }
    }

    /**
     * Finalized NAV event invocation.
     * It flags EventCoordinator as ready to process other events, fulfills the original promise, and schedules 
     * next event from the queue for processing.
     * 
     * @param {Object} event Event info containing NAV event invocation information
     * @param {Symbol} status Status of the event invocation (either INVOCATION_SUCCESSFUL or INVOCATION_FAILED)
     */
    private _finalizeNAVInvocation(invocationId: number, eventInfo: IEventInfo, status: string, error?: Error) {
        const { event, payload, fulfill } = eventInfo;
        isNavProcessingAnEvent = false;
        event.postInvokeCallback(payload);
        fulfill(status);

        setTimeout(() => {
            this._stateStore.dispatch(endNavEvent({
                invocationId,
                name: event.getLogName(),
                event,
                status,
                error: error && error.message
            }));

            this._processEventsQueue();
        });
    }

    /**
     * If no events are currently being processed in NAV, and NAV is not busy, and there are events in the event
     * queue, retrieves the next event from the queue (always by FIFO principle) and 
     */
    private _processEventsQueue(): void {
        // Sacrificing code clarity to test coverage, sorry for this. This is the only way to write this block to satisfy both the
        // TypeScript compiler and jest code coverage.
        let nextEvent: IEventInfo | undefined = undefined;
        if (isNavProcessingAnEvent || this._eventQueue.isEmpty() || (nextEvent = this._eventQueue.shift()) === undefined)
            return;

        this._debug?.log(`[EventCoordinator.processEventsQueue] Dequeueing next event: ${nextEvent.event.getLogName()}`);
        this._processSingleEventInvocation(nextEvent);
    }

    /**
     * Increases the invocation counter and sends an event for immediate invocation in NAV.
     * 
     * @param {Object} eventInfo Event info containing NAV event invocation information
     */
    private _processSingleEventInvocation(eventInfo: IEventInfo) {
        this._invokeNAV(eventInfo, ++nextInvocationId);
    }

    public busyChanged(busy: boolean): void {
        if (busy || isNavProcessingAnEvent || this._eventQueue.isEmpty())
            return;

        this._processEventsQueue();
    }

    /**
     * Decides if an event should be skipped. A skipped event is never sent to NAV and when en event is
     * skipped, its invocation resolves with SKIPPED_BUSY status.
     */
    private shouldSkip(source: NAVEvent): boolean {
        return !!(source.skipIfBusy && this._nav.busy);
    }

    /**
     * Decides if an event should be rejected. A rejected event is never sent to NAV and when an event is
     * rejected, its invocation resolves with REJECTED_DUPLICATE symbol.
     * An event is rejected if it is an exact duplicate of the event that was last sent to NAV, and the new
     * event is sent within the configured time threshold (e.g. 300 ms). This means that if a duplicate
     * invocation arrives within 300ms of the previous invocation, the new invocation is rejected.
     * 
     * @param {Event} source Source event which is evaluated against the reject criteria
     * @param {Object} payload Payload to be sent to NAV.
     */

    private shouldReject(source: NAVEvent, payload: any) {
        const dataStringified = JSON.stringify(payload);
        const timestamp = Date.now();
        const elapsed = timestamp - this._lastTimestamp;
        const reject = (
            source.rejectDuplicate
            && elapsed < REJECT_DUPLICATE_THRESHOLD
            && this._lastSource === source
            && this._lastDataStringified === dataStringified
        );

        this._lastSource = source;
        this._lastDataStringified = dataStringified;
        this._lastTimestamp = timestamp;

        return reject;
    }

    /**
     * Decides if an event can be processed immediately by the EventCoordinator
     */
    private canProcessImmediately(): boolean {
        return !this._nav.busy && !isNavProcessingAnEvent && this._eventQueue.isEmpty();
    }

    public async scheduleEvent(event: NAVEvent, payload: any): Promise<string> {
        if (this.shouldSkip(event)) {
            this._debug?.log(`Skipping because back end is busy: ${event.getLogName()}`);
            return Promise.resolve(SKIPPED_BUSY);
        }

        if (this.shouldReject(event, payload)) {
            this._debug?.log(`Rejecting duplicate event: ${event.getLogName()}`);
            return Promise.resolve(REJECTED_DUPLICATE);
        }

        return new Promise(fulfill => {
            const eventInfo: IEventInfo = { event, payload, fulfill, timestamp: Date.now() };
            if (this.canProcessImmediately()) {
                this._processSingleEventInvocation(eventInfo);
                return;
            }

            const queueContent = this._eventQueue.contentAsString(eventInfo);

            this._debug?.log(`Queueing event ${event.getLogName()} after ${queueContent}`);
            this._eventQueue.push(eventInfo);

            this._processEventsQueue();
        });
    }

    public static initialize(nav: NAVManager, stateStore: StateStore, debug: Debug): void {
        if (initialized)
            throw new InvalidOperationError("Attempting to initialize EventCoordinator that has been already initialized.");

        initialized = true;
        instance = new EventCoordinator(nav, stateStore, debug, INSTANTIATION_TOKEN);
    }

    public static get instance() {
        if (!initialized)
            throw new InvalidOperationError("Attempting to access instance of EventCoordinator that has not been previously initialized.");

        return instance;
    }
}
