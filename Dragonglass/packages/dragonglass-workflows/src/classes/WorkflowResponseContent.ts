export interface WorkflowResponseContent {
    id: number;
    actionId: number;
    workflowResponse?: any;
    queuedWorkflows: any[];
    context: any;
}