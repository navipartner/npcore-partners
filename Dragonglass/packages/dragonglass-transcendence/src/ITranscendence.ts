export interface ITranscendence {
    invokeFrontEndAsync(request: any): any;
    getNewButtonWorkflow(button: any): any;
    executeV1Workflow(initialContext: any, actionInfo: any, workflow: any, parameters: any, content: any, parent: any, fulfill: Function): void;
    actionActive(active: boolean): void;
    noSupport(method: string): void;
    abortAllWorkflows(): void;
};

