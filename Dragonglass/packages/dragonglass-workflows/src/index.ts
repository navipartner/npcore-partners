// TODO: Generally, this package is a naming mess, fix it
// It kind of proves this: https://martinfowler.com/bliki/TwoHardThings.html

export { WorkflowManager } from "./classes/WorkflowManager";
export { KnownWorkflows, runWorkflow } from "./classes/WorkflowOptionMapper"; // TODO: this one should not be named as it is, and maybe exports should be split into files
export { WorkflowRuntimeError } from "./errors/WorkflowRuntimeError";
export { Workflow, ACCEPT_NON_EXISTING_PARAMETERS } from "./classes/Workflow";
export { WorkflowPlugin } from "./classes/WorkflowPlugin";
export { WorkflowPluginRepository } from "./classes/WorkflowPluginRepository";
export { DataDriver } from "./data/DataDriver";
export { DataSource } from "./data/DataSource";
