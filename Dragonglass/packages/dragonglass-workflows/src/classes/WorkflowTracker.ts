import { WorkflowRuntimeError } from "./../errors/WorkflowRuntimeError";
import { WorkflowRuntimeCoordinator, RUNTIME_DISPOSE_TOKEN } from "./WorkflowRuntimeCoordinator";
import { CounterAwaiter } from "./CounterAwaiter";
import { GlobalErrorDispatcher, PropertyBag, Delegate_T } from "dragonglass-core";
import { WorkflowCallResponseAwaiter } from "./WorkflowCallResponseAwaiter";
import { WorkflowALInterface } from "./WorkflowALInterface";
import { WorkflowHardwareConnector, HARDWARE_DISPOSE_TOKEN } from "./WorkflowHardwareConnector";
import { WorkflowResponseContent } from "./WorkflowResponseContent";
import { WorkflowManager } from "./WorkflowManager";
import { DataManager } from "../data/DataManager";

var nextTrackerId = 0;
var workflowTrackers = {} as PropertyBag<WorkflowTracker>;

/**
 * Class that keeps track of an individual running instance of workflow code (code defined inside a C/AL action codeunit).
 * It is in charge of handling the workflow promise object (fulfilling, rejecting), and managing the workflow's lifecycle.
 * @param {string} name Action name (from C/AL action codeunit)
 * @param {WorkflowTracker} parent Parent tracker of this workflow tracker (used to keep track of nested workflows)
 */
export class WorkflowTracker {
    private _events: PropertyBag<Array<Function>> = {};
    private _awaiters: PropertyBag<WorkflowCallResponseAwaiter> = {};

    public runtimeCoordinator: WorkflowRuntimeCoordinator;
    public hardwareConnector: WorkflowHardwareConnector;
    public dataCoordinator: DataManager;

    public name: string;
    public id: number;
    public nested: boolean;
    public children: WorkflowTracker[];
    public aborted: boolean;
    public ended: boolean;
    public fulfilled: boolean;
    public rejected: boolean;
    public settled: boolean;
    public getResponder: Function;
    public getPopup: Function;
    public awaitAll: Function;
    public nav: WorkflowALInterface;
    public workflowResponse: any;
    public queuedWorkflows: any[] | undefined;

    constructor(name: string, parent?: WorkflowTracker) {
        this.name = name;
        this.id = ++nextTrackerId;
        this.nested = !!parent;
        this.children = [];
        workflowTrackers[this.id] = this;
        if (parent)
            parent.children.push(this);

        // States
        this.aborted = false;
        this.ended = false;
        this.fulfilled = false;
        this.rejected = false;
        this.settled = false;

        // Counters
        const respondAwaiter = new CounterAwaiter();
        const popupAwaiter = new CounterAwaiter();
        this.getResponder = respondAwaiter.start;
        this.getPopup = popupAwaiter.start;
        this.awaitAll = () => Promise.all([respondAwaiter.await(), popupAwaiter.await()]);

        // NAV Events
        this.nav = new WorkflowALInterface(this, WorkflowManager.errorReporter);

        // Runtime coordinator
        this.runtimeCoordinator = new WorkflowRuntimeCoordinator();
        this.hardwareConnector = new WorkflowHardwareConnector(WorkflowManager.hardwareConnector);
        this.dataCoordinator = new DataManager();
    }

    /**
     * Retrieves a tracker instance from the list of tracked instances.
     * @param {Number} id Id of the tracker to retrieve
     */
    static getTrackerById(id: number): WorkflowTracker {
        return workflowTrackers[id] || null;
    }

    /**
     * (Internal, do not call on instances)
     * Sets the ended state, and removes the tracker instance from the list of tracked instances.
     */
    _end(): void {
        this.runtimeCoordinator.__dispose__(RUNTIME_DISPOSE_TOKEN);
        this.hardwareConnector.__dispose__(HARDWARE_DISPOSE_TOKEN);

        this.ended = true;
        delete workflowTrackers[this.id];
    }

    /**
     * Marks the workflow promise state as fulfilled and settled. Fires the "fulfill" event and ends the workflow lifecycle tracking in
     * the workflow engine.
     * This method is invoked when the workflow promise resolves as fulfilled.
     */
    fulfill(): void {
        this.fulfilled = true;
        this.settled = true;
        this._invokeEvent("fulfill");
        this._end();
    }

    /**
     * Marks the workflow promise state as rejected and settled. Fires the "reject" event and ends the workflow lifecycle tracking in
     * the workflow engine.
     * This method is invoked when the workflow promise resolves as rejected.
     */
    reject(): void {
        this.rejected = true;
        this.settled = true;
        this._invokeEvent("reject");
        this._end();
    }

    /**
     * Aborts the current workflow. Fires the "abort" event and ends the workflow lifecycle in the workflow engine.
     */
    abort(): void {
        this.children.forEach(child => child.abort());
        this.aborted = true;
        this._invokeEvent("abort");
        this._end();
    }

    /**
     * Invokes an event on an WorkflowTracker object instance by invoking all handler callbacks bound to the specified event.
     * @param {string} event Name of the event to invoke
     * @param {*} content Content to be passed to event listeners
     * @returns {boolean} Indicates whether any event listeners were invoked
     */
    private _invokeEvent(event: string, content: any = undefined): boolean {
        var invoked = false;
        this._events && this._events[event] &&
            this._events[event].forEach(listener => {
                listener(content);
                invoked = true;
            });
        return invoked;
    }

    /**
     * Binds a callback handler to the specified event.
     * @param {string} event Name of the event to bind an event listener to
     * @param {function} handler Callback to be invoked when the event is invoked
     */
    addEventListener(event: string, handler: Function) {
        if (!this._events[event])
            this._events[event] = [];
        this._events[event].push(handler);
    }

    /**
     * Removes a callback handler from the specified event. For a hancler to be successfully removed, it must have been earlier added with addEventListener.
     * @param {string} event Name of the event to bind an event listener to
     * @param {function} handler Callback to be invoked when the event is invoked
     * @returns {boolean} Indicates whether the event listener was successfully removed.
     */
    removeEventListener(event: string, handler: Function): boolean {
        if (!this._events[event] || !this._events[event].includes(handler))
        {
            // TODO: Debug instead of console
            console.log("Attempting to remove an event listener that wasn't subscribed earlier.");
            return false;
        }

        this._events[event] = this._events[event].filter(f => f !== handler);
        return true;
    }

    /**
     * Registers a response awaiter (instance of {@link WorkflowCallResponseAwaiter}) for an invocation of a C/AL event.
     *
     * @param {number} id Unique Id if an individual invocation. It starts from 1 and is increased by 1 for each consecutive invocation
     * @param {function} callback Callback that is invoked when the awaited C/AL event receives its callback
     * @returns Instance of {@link WorkflowCallResponseAwaiter} object
     */
    awaitResponse(id: number, callback: Delegate_T<any>): WorkflowCallResponseAwaiter {
        return this._awaiters[id] = new WorkflowCallResponseAwaiter(callback);
    }

    /**
     * Processes the end-of-sequence (end of C/AL call stack) message from the C/AL after the C/AL OnAction call stack has been processed for a workflow.
     * @param content Represents workflow identification content (workflow and action id)
     */
    receiveResponse(content: WorkflowResponseContent) {
        content.workflowResponse && this.storeWorkflowResponse(content.workflowResponse);
        content.queuedWorkflows && this.storeQueuedWorkflows(content.queuedWorkflows);

        const awaiter = this._awaiters && this._awaiters[content.actionId];
        if (!awaiter) {
            GlobalErrorDispatcher.raiseCriticalError(new WorkflowRuntimeError("An expected AL workflow response awaiter is missing."));
            return;
        }

        awaiter.respond(content);
        this._invokeEvent("callCompleted", content.context);
    }

    private storeWorkflowResponse(value: any): void {
        this.workflowResponse = value;
    }

    private storeQueuedWorkflows(queues: any[]) {
        this.queuedWorkflows = queues;
    }
}
