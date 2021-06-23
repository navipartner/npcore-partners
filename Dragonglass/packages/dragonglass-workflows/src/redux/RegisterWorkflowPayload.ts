export interface RegisterWorkflowPayload {
    Workflow: {
        Name: string,
        Content: {
            engineVersion: string
        }
    }
}