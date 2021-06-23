import { WorkflowReduxRootState } from "./../redux/WorkflowReduxState";
import { WorkflowManager } from "./WorkflowManager";
import { Workflow } from "./Workflow";
import { GlobalErrorDispatcher } from "dragonglass-core";
import { WorkflowCache } from "./WorkflowCache";
import { StateStore } from "dragonglass-redux";

let workflows: any = {};
let options: any = {};
let sequences: any = {};
let viewWorkflows: any = {};

const getBuiltinWorkflow = (name: string) => workflows[name];

const getKnownOrViewWorkflowForType = async (type: string) => {
    const setup = Workflow.getPerViewSetup();
    if (setup[type]) {
        const action = setup[type];
        let workflow;
        if (!viewWorkflows[action.action]) {
            workflow = await WorkflowCache.retrieveWorkflow(action.action);
            viewWorkflows[action.action] = workflow;
        } else {
            workflow = viewWorkflows[action.action];
        }

        return { ...workflow, __setup__: action };
    }
    return getBuiltinWorkflow(options[`${type}Workflow`]) || getBuiltinWorkflow(type);
}

export class KnownWorkflows {
    static initialize(store: StateStore) {
        store.subscribeSelector<WorkflowReduxRootState, WorkflowReduxRootState>(
            (next, prev) => {
                if (!next.workflows || !next.options || next.workflows === prev.workflows && next.options === next.options &&
                    (next.options.customerWorkflow === prev.options.customerWorkflow &&
                        next.options.itemWorkflow === prev.options.itemWorkflow &&
                        next.options.lockWorkflow === prev.options.lockWorkflow &&
                        next.options.paymentWorkflow === prev.options.paymentWorkflow &&
                        next.options.unlockWorkflow === prev.options.unlockWorkflow &&
                        next.options.sequences === prev.options.sequences))
                    return false;

                return next;
            },
            state => {
                workflows = state.workflows.workflows;
                sequences = state.workflows.sequences;
                options = state.options;
            }
        )
    }

    static customer(actionInfo: any, parent: any) {
        return runWorkflow("customer", { ...actionInfo }, parent);
    }

    static item(actionInfo: any, parent: any) {
        return runWorkflow("item", { ...actionInfo }, parent);
    }

    static lock(actionInfo: any, parent: any) {
        return runWorkflow("lock", { ...actionInfo }, parent);
    }

    static login(actionInfo: any, parent: any) {
        return runWorkflow("login", { ...actionInfo }, parent);
    }

    static payment(actionInfo: any, parent: any) {
        return runWorkflow("payment", { ...actionInfo }, parent);
    }

    static textEnter(actionInfo: any, parent: any) {
        return runWorkflow("textEnter", { ...actionInfo }, parent)
    }

    static unlock(actionInfo: any, parent: any) {
        return runWorkflow("unlock", { ...actionInfo }, parent);
    }
}

export const runWorkflow = (type: string, actionInfo: any, parent: any) => new Promise<void>(async fulfill => {
    let initialContext = null;
    if (typeof actionInfo._getInitialContext === "function") {
        initialContext = actionInfo._getInitialContext();
        delete actionInfo._getInitialContext;
    }
    if (actionInfo._additionalContext)
        initialContext = { ...initialContext, _additionalContext: actionInfo._additionalContext }

    const action = await getKnownOrViewWorkflowForType(type);
    if (!action) {
        GlobalErrorDispatcher.raiseCriticalError(`[WorkflowManager] Attempting to run workflow of unsupported type "${type} or without a configured workflow for that type."`);
        fulfill();
        return;
    }
    const code = actionInfo.Code && { [`${type}No`]: actionInfo.Code };
    const parameters = { ...actionInfo.Parameters, ...(actionInfo._nested ? {} : action.Parameters), ...code };

    const version = action.Workflow.Content && action.Workflow.Content.engineVersion || "1.0";
    switch (version) {
        case "1.0":
            WorkflowManager.transcendence.executeV1Workflow(initialContext, actionInfo, action.Workflow, parameters, actionInfo.Content || {}, parent, fulfill);
            break;
        case "2.0":
            const viewParameters = action.__setup__ && action.__setup__.parameters || {};
            const viewContext = action.__setup__ && action.__setup__.context || {};
            initialContext = { ...(initialContext || {}), ...viewContext };
            const parametersV2 = { ...action.Parameters, ...parameters, ...viewParameters };
            const metadata = action.Content && action.Content.Metadata || {};
            const actionV2 = {
                ...action,
                Workflow: { ...action.Workflow },
                Parameters: { ...parametersV2 }
            };
            const initializer: any = { action: actionV2, metadata: { ...metadata } };
            if (initialContext)
                initializer.context = initialContext;
            const workflowV2 = new Workflow(initializer);
            workflowV2.execute().then(fulfill, fulfill);

            break;
        default:
            GlobalErrorDispatcher.raiseCriticalError(`[WorkflowManager] Attempting to run workflow ${action.Workflow.Name} with unsupported engine version ${version}`);
            fulfill();
            break;
    }
});
