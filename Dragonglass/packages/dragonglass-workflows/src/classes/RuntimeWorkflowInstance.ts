import { DataManager } from "./../data/DataManager";
import { WorkflowRuntimeCoordinator } from "./WorkflowRuntimeCoordinator";
import { IHardwareConnector } from "../interfaces/IHardwareConnector";

/**
 * Represents an instance of a workflow object passed to the workflow JavaScript code. This object is accessed by
 * custom-written JavaScript code stored in back-end action codeunits.
 */
export interface RuntimeWorkflowInstance {
    name: string;
    popup: any, // TODO: do we need an actual class here?
    runtime: WorkflowRuntimeCoordinator,
    hwc: IHardwareConnector,
    data: DataManager
}
