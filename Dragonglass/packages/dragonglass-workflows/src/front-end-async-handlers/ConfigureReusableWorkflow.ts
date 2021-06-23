import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { WorkflowManager } from "../classes/WorkflowManager";
import { registerWorkflow } from "../redux/workflows-actions";

export class ConfigureReusableWorkflow extends FrontEndAsyncRequestHandler {
    handle(request: any) {
        WorkflowManager.stateStore.dispatch(registerWorkflow(request.Action));
    }
}
