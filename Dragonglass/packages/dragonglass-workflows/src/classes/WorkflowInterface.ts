// TODO: Sort out types in this file

import { ALRuntimeError } from "../errors/ALRuntimeError";
import { ALBusyError } from "./../errors/ALBusyError";
import { ALError } from "./../errors/ALError";
import { Workflow } from "./Workflow";
import { GlobalErrorDispatcher } from "dragonglass-core";
import { WorkflowManager } from "./WorkflowManager";
import { WorkflowRuntimeDescription } from "./WorkflowRuntimeDescription";
import { ActionParameters } from "./ActionParameters";
import { RuntimeWorkflowInstance } from "./RuntimeWorkflowInstance";
import { WorkflowRuntimeScope } from "../interfaces/RuntimeScope";

const operationErrorMessages: any = {
    popup: "Attempting to show a popup in the context of a completed workflow.",
    complete: "Attempting to complete a workflow that has already been completed.",
    respond: "Attempting to invoke NAV from a workflow that has been completed earlier.",
    fail: "Attempting to fail a workflow that has already been either completed or failed.",
    run: "Attempting to nest a workflow in the context of a completed workflow.",
    queue: "Attempting to queue a workflow in the context of a completely processed workflow. Queue your workflow before calling workflow.complete()."
};

/**
 * Class that contains WorkflowInterface object that's used by the workflow code through the built-in variable "workflow" that allows the
 * workflow code to communicate with the workflow functionality (completing, failing, responding to C/AL) and access workflow state.
 * @param {object} interface Inline object containing references necessary for constructing the WorkflowInterface instance
 */
export class WorkflowInterface {
    [key: string]: any;

    public scope: WorkflowRuntimeScope;
    public complete: Function;
    public fail: Function;
    public keepAlive: Function;
    public respond: Function;
    public respondWithSilentThrow: Function;
    public queue: Function;
    public run: Function;

    private _bindToThis(func: Function): Function {
        return func.bind(this);
    }

    constructor(intf: WorkflowRuntimeDescription) {
        let done = false;
        let keptAlive = false;
        let fail = false;
        let queueProcessed = false;

        const queue: any[] = [];
        const popup = WorkflowManager.createPopupCoordinator({
            open: () => {
                makeSureNotDone("popup");
                return intf.tracker.getPopup();
            }
        });

        function processQueue() {
            queueProcessed = true;
            return new Promise<void>((fulfill, reject) => {
                if (queue.length === 0) {
                    fulfill();
                    return;
                }

                function processNext() {
                    const { action, context } = queue.shift();
                    Workflow.run(action, context, intf.tracker).then(() => {
                        queue.length === 0 ? fulfill() : processNext();
                    }, reject);
                }

                processNext();
            });
        }

        /**
         * Indicates whether the workflow has been fully completed, which can be either successfully or unsuccessfully.
         * A completed workflow does not allow:
         * - completing
         * - failing
         * - showing popups
         * - responding to NAV
         */
        Object.defineProperty(this, "done", {
            get: () => {
                return done;
            }
        });

        Object.defineProperty(this, "keptAlive", {
            get: () => {
                return keptAlive;
            }
        });

        Object.defineProperty(this, "popup", {
            value: popup,
            configurable: false,
            writable: false
        });

        Object.defineProperty(this, "runtime", {
            value: intf.tracker.runtimeCoordinator,
            configurable: false,
            writable: false
        });

        Object.defineProperty(this, "hwc", {
            value: intf.tracker.hardwareConnector,
            configurable: false,
            writable: false
        });

        Object.defineProperty(this, "data", {
            value: intf.tracker.dataCoordinator,
            configurable: false,
            writable: false
        });

        function makeSureNotDone(operation: string) {
            if (!done)
                return;
            fail = true;
            intf.reject("Workflow is already done.");
            GlobalErrorDispatcher.raiseCriticalError(operationErrorMessages[operation] + "\nRestructure your code to call workflow.complete() only after all of the work inside the workflow has been completed, and make sure to call it only once.\nOnce you call workflow.complete(), or workflow.fail(), you must not call anything else.");
        }

        /**
         * Completes the currently executing workflow. This method represents an end of the managed workflow lifecycle from the perspective of
         * the action workflow code.
         * While there may still be JavaScript code running after this, that code must not interact with the "workflow" object.
         */
        this.complete = this._bindToThis((context: any) => {
            makeSureNotDone("complete");
            done = true;
            intf.tracker.awaitAll().then(
                () => {
                    processQueue().then(
                        () => {
                            if (intf.error || fail) {
                                intf.reject(intf.error ? intf.error.message : "Failing because of invalid flow")
                            } else {
                                intf.fulfill(context);
                            }
                        },
                        () => intf.reject("Queue processing failed."));
                });
        });

        /**
         * Completes the currently executing workflow by failing it. This method represents an end of the managed workflow lifecycle from the
         *  perspective of the action workflow code.
         * While there may still be JavaScript code running after this, that code must not interact with the "workflow" object.
         * @param {*} reason Indicates the reason for failing the workflow.
         */
        this.fail = this._bindToThis((reason: any) => {
            makeSureNotDone("fail");
            console.warn("Failing workflow id [" + intf.tracker.id + "]" + ((typeof reason === "string" && " due to: " + reason) || ""));
            done = true;
            intf.reject(reason);
        });

        /**
         * Marks this workflow to stay alive, which means that it won't be automatically completed after its async function execution completes.
         * A workflow kept alive indicates that the workflow promise remains unresolved until the workflow code manually invokes the
         * workflow.complete() function.
         * Keeping alive a workflow that has already completed will have no effect.
         */
        this.keepAlive = this._bindToThis(() => {
            console.log(`[WorkflowInterface] Keeping workflow ${intf.tracker.id} alive upon explicit request.`)
            keptAlive = true;
        });

        const respond = this._bindToThis(async (step: string, context: any, handleError: boolean) => {
            makeSureNotDone("respond");

            const sendContext = Object.assign({}, this._view_action_context, this._per_view_setup, this.context, typeof context === "object" && context || {});
            sendContext.parameters = this.scope.parameters.getRawObject();
            sendContext.workflowId = intf.tracker.id;

            const responder = intf.tracker.getResponder();
            const response = await intf.tracker.nav.action(typeof step === "string" && step || "", sendContext);
            if (response instanceof ALError) {
                // ALError instances have special handling requirements, they are signals from the WorkflowALInterface
                intf.error = response.message;

                if (response instanceof ALBusyError) {
                    GlobalErrorDispatcher.raiseCriticalError(`[WorkflowInterface] ${response.message}`);
                    response.handle();
                }

                if (response instanceof ALRuntimeError) {
                    if (handleError)
                        response.handle();
                }

                setTimeout(() => intf.catchErrorAndReject(response));
                throw response;
            }
            responder.resolve();
            return response;
        });

        /**
         * Invokes the OnAction event in C/AL. It indicates the optional step name and passes optional context object to C/AL.
         * @param {string} [step] Workflow step, for the purpose of structuring OnAction code in C/AL
         * @param {object} [context] Context to be passed to C/AL (on top of already existing context)
         * @returns {Promise} Promise that resolves when the entire C/AL call stack has been completed
         */
        this.respond = this._bindToThis(async (step: string, context: any) => await respond(step, context, true));

        /**
         * Invokes the OnAction event in C/AL. It indicates the optional step name and passes optional context object to C/AL.
         * If there is an unhandled runtime error, it doesn't show error UI, but throws a what would previously be a "Don't panic"
         * kind of error.
         */
        this.respondWithSilentThrow = this._bindToThis(async (step: string, context: any) => await respond(step, context, false));

        /**
         * Queues a workflow. Queueing a workflow makes it run after the currently running workflow completes execution.
         * 
         * @param {Object} [name] The name of the workflow to queue.
         * @param {Object} [context] Context of the workflow to queue.
         */
        this.queue = this._bindToThis((name: string, context: any) => {
            if (queueProcessed) {
                GlobalErrorDispatcher.raiseCriticalError(operationErrorMessages("queue"));
                return;
            }

            queue.push({ action: name, context: context });
        });

        /**
         * Nests a workflow. Nesting a workflow makes it run in parallel with the current workflow.
         * 
         * @param {Object} [action] Action of the workflow to queue.
         * @param {Object} [context] Context of the workflow to next.
         * @returns {Promise} Promise that resolves when the nested workflow completes execution.
         */
        this.run = this._bindToThis((action: string, context: any) => {
            makeSureNotDone("run");
            return Workflow.run(action, context, intf.tracker);
        });

        Object.defineProperty(this, "context", {
            value: intf.context
        });

        Object.defineProperty(this, "name", {
            get: () => intf.name
        });

        const state = WorkflowManager.stateStore.getState<any>();
        const perViewSetup = Workflow.getPerViewSetup(state.view.active);
        this._per_view_setup = Object.keys(perViewSetup || {}).length ? { _workflows_setup: perViewSetup } : {};
        this._view_action_context = perViewSetup._view_action_context ? { _view_action_context: perViewSetup._view_action_context } : {};
        this.scope = {
            viewWorkflowSetup: perViewSetup,
            actionContext: perViewSetup._view_action_context || {},
            parameters: new ActionParameters(intf.parameters),
            metadata: intf.metadata,
            captions: WorkflowManager.localization.localizeAction(intf.name),
            view: state.view.active,
            data: state.data
        };

        intf.tracker.addEventListener("callCompleted", this._bindToThis((context: any) => {
            for (let prop in context) {
                if (!context.hasOwnProperty(prop))
                    continue;

                const arr = prop.split(".");
                if (arr.length === 1) {
                    this.context[prop] = context[prop];
                    continue;
                }
            }

            if (!intf.tracker.queuedWorkflows)
                return;

            intf.tracker.queuedWorkflows.forEach(queue => {
                const parts = queue.split(";", 2);
                try {
                    this.queue(parts[0], parts[1] ? JSON.parse(parts[1]) : {});
                }
                catch (e) {
                    GlobalErrorDispatcher.raiseCriticalError("Invalid queue context for " + parts[0] + ": " + parts[1]);
                }
            });

        }));
    }

    toRuntimeWorkflowInstance(): RuntimeWorkflowInstance {
        return this as unknown as RuntimeWorkflowInstance;
    }
}
