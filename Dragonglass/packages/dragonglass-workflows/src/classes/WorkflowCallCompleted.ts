import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { FALLBACK_TO_TRANSCENDENCE } from "dragonglass-front-end-async";
import { WorkflowTracker } from "./WorkflowTracker";
import { WorkflowResponseContent } from "./WorkflowResponseContent";
import { WorkflowCompletedAsyncRequest } from "../interfaces/WorkflowCompletedAsyncRequest";

export class WorkflowCallCompleted extends FrontEndAsyncRequestHandler {
    completeWorkflowCall(content: WorkflowResponseContent) {
        const tracker = WorkflowTracker.getTrackerById(content.id);
        tracker && tracker.receiveResponse(content);
    }

    handle(request: WorkflowCompletedAsyncRequest): any {
        if (request.Content.workflowEngine !== "2.0")
            return FALLBACK_TO_TRANSCENDENCE;

        const content: any = request.Content._trace
            ? {
                duration: request.Content._trace.durationBefore
                    ? {
                        before: request.Content._trace.durationBefore
                    }
                    : {
                        all: request.Content._trace.durationAll,
                        action: request.Content._trace.durationAction,
                        data: request.Content._trace.durationData,
                        overhead: request.Content._trace.durationOverhead
                    },
                raw: request.Content._trace
            }
            : {};

        if (!request.Success) {
            content.error = {
                silent: !request.ThrowError,
                message: request.ErrorMessage
            };
        };

        content.id = request.WorkflowId;
        content.actionId = request.ActionId;
        content.context = request.Content.context || {};
        if (request.Content.hasOwnProperty("workflowResponse"))
            content.workflowResponse = request.Content.workflowResponse;
        if (request.Content.hasOwnProperty("queuedWorkflows"))
            content.queuedWorkflows = request.Content.queuedWorkflows;

        this.completeWorkflowCall(content);
    }
}
