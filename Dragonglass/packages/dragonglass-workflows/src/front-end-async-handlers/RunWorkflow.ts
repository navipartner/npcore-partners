import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { NAVEventFactory, NAVInvoker } from "dragonglass-nav";
import { Workflow } from "../classes/Workflow";

const getObject = (request: any, name: any) => {
    const result = request.Content[name];
    switch (typeof result) {
        case "string":
            return JSON.parse(result);
        case "object":
            return result || {};
    }
    return {};
}

export class RunWorkflow extends FrontEndAsyncRequestHandler {
    private _onCompleted: NAVInvoker<any>;
    private _onFailed: NAVInvoker<any>;

    constructor() {
        super();
        
        this._onCompleted = NAVEventFactory.method("OnRunWorkflowCompleted");
        this._onFailed = NAVEventFactory.method("OnRunWorkflowFailed");        
    }

    async handle(request: any) {
        try {
            const parameters = getObject(request, "parameters");
            const context = getObject(request, "context");
            await Workflow.run(request.Content.action, { context, parameters });
            this._onCompleted.raise({ id: request.Content.id })
        }
        catch (e) {
            this._onFailed.raise({ id: request.Content.id, error: `${e}` });
        }
    }
};
