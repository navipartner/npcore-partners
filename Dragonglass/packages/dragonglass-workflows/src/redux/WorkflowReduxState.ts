export interface WorkflowReduxWorkflowState {
    workflows: WorkflowReduxState;
}

export interface WorkflowReduxOptionsState {
    options: any;
    
}

export interface WorkflowReduxRootState extends WorkflowReduxWorkflowState, WorkflowReduxOptionsState {
};

export interface WorkflowReduxState {
    workflows: any;
    sequences: any;
};
