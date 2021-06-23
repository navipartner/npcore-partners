import { ALRuntimeError } from "../errors/ALRuntimeError";
import { ALBusyError } from "./../errors/ALBusyError";
import { NAVEventFactory, NAVInvoker } from "dragonglass-nav";
import { GlobalErrorDispatcher, ErrorReporter, Delegate_T, Delegate } from "dragonglass-core";
import { WorkflowManager } from "./WorkflowManager";
import { WorkflowTracker } from "./WorkflowTracker";

/**
 * Contains C/AL event interface that allows invoking events in NAV.
 * @param tracker Represents the workflow tracker object that represents an individual workflow state
 */
export class WorkflowALInterface {
    private static _respond: NAVInvoker<any> | null = null;
    private static get respond() {
        if (this._respond === null)
            this._respond = NAVEventFactory.method({ name: "OnAction20", appendDataStates: true });
        return this._respond;
    }

    private _onActionBusy: boolean;
    private _onAction: NAVInvoker<any>;
    private _actionId: number = 0;
    private _tracker: WorkflowTracker; // TODO: must be of WorkflowTracker type!!!!
    private _errorReporter: ErrorReporter;

    constructor(tracker: any, errorReporter: ErrorReporter) {
        this._tracker = tracker;
        this._actionId = 0;
        this._onAction = WorkflowALInterface.respond;
        this._onActionBusy = false;
        this._errorReporter = errorReporter;
    }

    /**
     * (Internal) Handles the error if it was passed by AL.
     * @param {Object} error Error object (or undefined, if not present)
     * @returns {*} If error is present, returns an instance of ALRuntimeError with details, otherwise returns null
     */
    async _handleResponseErrorIfNeeded(error: any): Promise<ALRuntimeError | null> {
        if (!error)
            return null;

        const alError = new ALRuntimeError(error.message, error.silent, this._errorReporter);
        if (!error.silent) {
            GlobalErrorDispatcher.raiseUnhandledALError(error.message)
            await alError.showALError();
        } else {
            GlobalErrorDispatcher.raiseSilentALError(error.message)
        }

        return alError;
    }

    /**
     * (Internal) Returns a function that processes AL response.
     * @param {Function} fulfill Callback to invoke to fulfill the outer promise.
     */
    _getALResponseHandler(fulfill: Function): Delegate_T<any> {
        return (async (response: any) => {
            const error = await this._handleResponseErrorIfNeeded(response.error);
            fulfill(error || this._tracker.workflowResponse);
        }).bind(this);
    }

    /**
     * (Internal; Pure) Builds the context argument for AL.
     * @param {Object} context Original context to be passed to AL
     */
    _buildALContextArgument(context: any): any {
        return {
            ...(typeof context === "object" ? context : {}),
            ...WorkflowManager.stateStore.getDataStates(),
            workflowEngine: "2.0"
        };
    }

    /**
     * (Internal; Pure) Creates AL invocation arguments array.
     * @param {String} step Step moniker.
     * @param {Object} context Context to be passed to AL.
     * @returns Arguments object for AL invocation.
     */
    _getALInvocationArgs(step: string, context: any): any {
        const alContext = this._buildALContextArgument(context);
        return {
            name: this._tracker.name,
            step: step || "",
            id: this._tracker.id,
            actionId: this._actionId,
            context: alContext
        };
    }

    /**
     * Internally invoked from the "respond" method
     * Invokes the OnAction event in C/AL. Returns a promise that resolves when the entire OnAction call sequence has been fully
     * processed.
     * @param {String} step Step moniker (optional). AL uses this value to identify the part of logic to execute.
     * @param {Object} context Workflow context that's being kept in sync between AL and JavaScript workflow function.
     */
    async action(step: string, context: any): Promise<any> {
        // Must return a Promise, instead of entire function being async, because the promise is resolved from outside this function.
        return new Promise(async (fulfill: Delegate_T<any>) => {
            if (this._onActionBusy) {
                fulfill(new ALBusyError());
                return;
            }

            this._onActionBusy = true;
            const awaiter = this._tracker.awaitResponse(++this._actionId, this._getALResponseHandler(fulfill));
            await this._onAction.raise(this._getALInvocationArgs(step, context))
            this._onActionBusy = false;
            awaiter.completeCall();
        });
    }
}
