import { WorkflowTracker } from "./WorkflowTracker";

export interface WorkflowRuntimeDescription {
    name: string;
    fulfill: Function;
    reject: Function;
    catchErrorAndReject: Function,
    tracker: WorkflowTracker;
    parameters: any;
    metadata: any;
    context: any;
    dataSource: any;
    error?: any;
}
