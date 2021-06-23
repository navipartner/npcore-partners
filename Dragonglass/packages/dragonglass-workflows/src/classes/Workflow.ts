import { WorkflowInterface } from "./WorkflowInterface";
import { WorkflowManager } from "./WorkflowManager";
import { ALError } from "./../errors/ALError";
import { GlobalErrorDispatcher, GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { WorkflowTracker } from "./WorkflowTracker";
import { WorkflowCache } from "./WorkflowCache";
import { RuntimeWorkflowInstance } from "./RuntimeWorkflowInstance";
import { ActionWrapper } from "./ActionWrapper";
import { FunctionLibrary } from "./FunctionLibrary";
import { ActionDescription } from "./ActionDescription";
import { WorkflowPluginRepository } from "./WorkflowPluginRepository";

/** Indicates that workflow will accept parameters that are not defined in the action */
export const ACCEPT_NON_EXISTING_PARAMETERS = Symbol();

function transformParameters(sourceContextParameters: any, sourceWorkflowActionParameters: any, acceptNonExisting: boolean = false) {
    const actionParameters = JSON.parse(JSON.stringify(sourceWorkflowActionParameters || {}));

    for (let p in sourceContextParameters) {
        if (sourceContextParameters.hasOwnProperty(p) && actionParameters.hasOwnProperty(p)) {
            const options = actionParameters[`_option_${p}`];
            if (options) {
                if (options.hasOwnProperty(sourceContextParameters[p])) {
                    actionParameters[p] = options[sourceContextParameters[p]];
                } else {
                    let hasNumberMatch = false;
                    if (typeof sourceContextParameters[p] === "number") {
                        for (let option in options) {
                            if (options.hasOwnProperty(option) && options[option] === sourceContextParameters[p]) {
                                actionParameters[p] = sourceContextParameters[p];
                                hasNumberMatch = true;
                                break;
                            }
                        }
                    }
                    if (!hasNumberMatch)
                        GlobalErrorDispatcher.raiseCriticalError(`[WorkflowInterface] Non-existing option specified: ${sourceContextParameters[p]}`);
                }
            } else {
                let declaredType = typeof actionParameters[p];
                let actualType = typeof sourceContextParameters[p];
                if (declaredType === actualType) {
                    actionParameters[p] = sourceContextParameters[p];
                } else {
                    GlobalErrorDispatcher.raiseCriticalError(`[WorkflowInterface] Mismatching parameter type: ${p} (declared type is ${declaredType}, actual type is ${actualType})`);
                }
            }
        }
        else {
            if (acceptNonExisting)
                continue;

            GlobalErrorDispatcher.raiseCriticalError(`[WorkflowInterface] Non-existing parameter specified: ${p}`)
        }
    }

    return actionParameters;
}

/**
 * Executes the workflow code through evaluation. It is defined in an isolated scope from all other workflow functionality, to prevent  accidental
 * or malicious handling access to internal workflow state information. It does provide access to all global scope, though.
 * @param {object} workflow Represents interface that can be accessed by dynamically execute code through its local scope.
 * @param {string} code Code that will be dynamically executed.
 */
async function executeCode(workflow: RuntimeWorkflowInstance, code: string, catchErrorAndReject: Function): Promise<any> {
    try {
        const workflowFunction = await FunctionLibrary.getFunction(workflow.name, code);
        return await workflowFunction(
            workflow,
            workflow.popup,
            workflow.runtime,
            workflow.hwc,
            workflow.data
        );
    } catch (e) {
        catchErrorAndReject(e);
    };
};

const perViewContextObject: any = {
    activeView: "",
    setup: {}
};

/**
 * Class that represents the entry point into the workflow engine. It is in charge of creating the promise object for the
 * workflow, that is in charge of synchronizing workflow execution in the workflow engine.
 * @param {object} button The button object that was clicked to invoke the workflow
 * @param {WorkflowTracker} parent The parent tracker of this workflow (used for nested workflows)
 */
export class Workflow {
    public execute: Function;

    constructor(button: ActionWrapper, parent?: WorkflowTracker) {
        const workflowDefinition = button.action.Workflow || {};
        const parameters = { ...button.action.Parameters };
        const metadata = button.metadata;
        const context = { ...(button.context || {}) };
        if ((button as any)._additionalContext) {
            context._additionalContext = (button as any)._additionalContext;
        }
        const { before, after } = WorkflowManager.getSequencesForWorkflow(workflowDefinition.Name);

        if (Array.isArray(button.plugins)) {
            for (let name of button.plugins) {
                let plugin = WorkflowPluginRepository.get(name);
                if (plugin) {
                    plugin.processParameters(parameters);
                    plugin.processContext(context);
                }
            }
        }

        if (!workflowDefinition.Steps || !workflowDefinition.Steps.length)
            workflowDefinition.Steps = [{ Code: "" }];

        const trackerName = workflowDefinition
            ? workflowDefinition.Name
            : parent
                ? `ChildOf-${parent.name}`
                : '(unnamed workflow';

        /**
         * Executes the workflow code.
         */
        this.execute = (dataSource: any, completionCallback: Function) => {
            const factory = () => {
                GlobalEventDispatcher.raise(GLOBAL_EVENTS.WORKFLOW_START, { workflow: trackerName });
                const tracker = new WorkflowTracker(trackerName, parent);
                const logMoniker = `${parent ? "child" : "top-level"} workflow${parent ? ` of ${parent.name}` : ""}`;
                const startTimestamp = Date.now();

                console.log(`[Workflow] Starts ${trackerName} as a ${logMoniker}`);

                const promise = new Promise((fulfill, reject) => {
                    const catchErrorAndReject = ((e: Error) => {
                        if (!(e instanceof ALError) || !e.ALError.handled)
                            GlobalErrorDispatcher.raiseCriticalError(`[Workflow] Unhandled error while executing workflow ${trackerName}: ${e}`);
                        reject(e);
                        return;
                    });

                    if (button.action.Content && button.action.Content.hasOwnProperty("requirePosUnitType") && button.action.Content.requirePosUnitType != WorkflowManager.getOption("posUnitType")) {
                        reject(new Error(`Workflow configuration mismatch: action ${trackerName} requires POS Unity Type to be ${WorkflowManager.getOption("posUnitType")}, and it's ${button.action.Content.requirePosUnitType}.`));
                        return;
                    }

                    const workflow = new WorkflowInterface({
                        name: trackerName,
                        fulfill,
                        reject,
                        catchErrorAndReject,
                        tracker,
                        parameters,
                        metadata,
                        context,
                        dataSource
                    });

                    executeCode(workflow.toRuntimeWorkflowInstance(), workflowDefinition.Steps[0].Code, catchErrorAndReject)
                        .then(result =>
                            !workflow.keptAlive &&
                            workflow.complete(result))
                        .catch(reject);
                });

                promise.then(
                    // Success
                    () => {
                        console.log(`[Workflow] Completes ${trackerName} as a ${logMoniker}, duration ${Date.now() - startTimestamp}ms`);
                        GlobalEventDispatcher.raise(GLOBAL_EVENTS.WORKFLOW_COMPLETE, { workflow: trackerName });

                        const complete = () => {
                            tracker.fulfill();
                            typeof completionCallback === "function" && completionCallback();
                        };

                        if (after) {
                            const queue = [...after];
                            queue.sort((left, right) => {
                                if (left.priority < right.priority)
                                    return -1;
                                if (left.priority > right.priority)
                                    return 1;
                                return 0;
                            });

                            if (queue.length === 0) {
                                complete();
                                return;
                            }

                            function processNext() {
                                if (queue.length === 0) {
                                    complete();
                                    return;
                                }

                                const next = queue.shift();
                                WorkflowCache.retrieveWorkflow(next.action)
                                    .then(
                                        wkf => {
                                            const workflow = new Workflow({ action: JSON.parse(JSON.stringify(wkf)) } as ActionWrapper);
                                            workflow
                                                .execute()
                                                .then(processNext, processNext)
                                        },
                                        () => processNext());
                            };

                            processNext();
                        } else {
                            complete();
                        }
                    },

                    // Failure
                    reason => {
                        console.warn(`[Workflow] Execution of ${trackerName} as a ${logMoniker} failed with "${reason}" after ${Date.now() - startTimestamp}ms`);
                        GlobalEventDispatcher.raise(GLOBAL_EVENTS.WORKFLOW_FAIL, { workflow: trackerName, reason: reason });
                        tracker.reject();
                        typeof completionCallback === "function" && completionCallback();
                    });
                return promise;
            };

            if (before) {
                return new Promise((fulfill, reject) => {
                    const queue = [...before];
                    queue.sort((left, right) => {
                        if (left.priority < right.priority)
                            return -1;
                        if (left.priority > right.priority)
                            return 1;
                        return 0;
                    });
                    if (queue.length === 0) {
                        factory().then(fulfill, reject);
                        return;
                    };

                    function processNext() {
                        if (queue.length === 0) {
                            factory().then(fulfill, reject);
                            return;
                        }

                        const next = queue.shift();
                        WorkflowCache.retrieveWorkflow(next.action)
                            .then(
                                wkf => {
                                    const workflow = new Workflow({ action: JSON.parse(JSON.stringify(wkf)) } as ActionWrapper);
                                    workflow
                                        .execute()
                                        .then(processNext, reject)
                                },
                                () => reject());
                    };

                    processNext();
                });
            } else {
                return factory();
            }
        }
    }

    static definePerViewWorkflowSetup(setup: any, tag: string): void {
        perViewContextObject[tag] = setup || {};
    }

    /**
     * Retrieves workflow configuration options for the view identified by the tag.
     * 
     * @param tag View tag
     */
    static getPerViewSetup(tag?: string): any {
        if (!tag) {
            var state = WorkflowManager.stateStore.getState<any>();
            tag = state.view.active;
        }
        if (!tag)
            return {};

        return JSON.parse(JSON.stringify(perViewContextObject[tag] || {}));
    }

    /**
     * Returns a promise that resolves when the workflow indicated by the action name and context has executed. It retrieves the
     * workflow from the workflow cache if it hasn't been run earlier.
     *
     * @static
     * @param {String} actionName Name of the action to run
     * @param {Object} actionContext Context of the object to run
     * @param {WorkflowTracker} tracker Tracker to keep track of the workflow execution.
     * @returns Promise
     * @memberof Workflow
     */
    static run(actionName: string, actionContext: any, tracker?: WorkflowTracker) {
        if (!tracker)
            tracker = new WorkflowTracker(`Direct_${actionName}`);

        return new Promise((fulfill, reject) => {
            if (typeof actionContext !== "object" || !actionContext)
                actionContext = {};

            function runWorkflow(actionToRun: ActionDescription) {
                const workflow: any = { action: JSON.parse(JSON.stringify(actionToRun)) };
                if (actionContext.context)
                    workflow.context = actionContext.context;

                const acceptsNonExistingParameters = !!actionContext[ACCEPT_NON_EXISTING_PARAMETERS];
                workflow.action.Parameters = transformParameters(
                    actionContext.parameters,
                    workflow.action.Parameters,
                    acceptsNonExistingParameters);

                const nested = new Workflow(workflow, tracker);
                nested
                    .execute()
                    .then(fulfill)
                    .catch(reject);
            }

            WorkflowCache.retrieveWorkflow(actionName)
                .then(runWorkflow)
                .catch(reject);
        });
    }
}
