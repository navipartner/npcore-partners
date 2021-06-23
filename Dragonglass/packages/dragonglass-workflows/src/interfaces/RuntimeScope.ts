import { ActionParameters } from "../classes/ActionParameters";

export interface WorkflowRuntimeScope {
    viewWorkflowSetup: {},
    actionContext: {},
    parameters: ActionParameters,
    metadata: any,
    captions: {[key: string]: string},
    view: string,
    data: any
}
