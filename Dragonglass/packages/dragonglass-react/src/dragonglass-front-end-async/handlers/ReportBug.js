import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { GlobalErrorDispatcher } from "dragonglass-core";

export class ReportBug extends FrontEndAsyncRequestHandler {
    constructor(transcendence) {
        super();
        this._transcendence = transcendence;
    }

    handle(request) {
        if (request.Content.InvalidCustomMethod) {
            this._transcendence.noSupport(request.Content.InvalidCustomMethod);
            return;
        }

        if (request.Content.warning) {
            console.log(request.ErrorText.replace(/\\/g, "\n"));
            return;
        }

        this._transcendence.abortAllWorkflows();
        GlobalErrorDispatcher.raiseCriticalError(`[ReportBug] ${request.ErrorText.replace(/\\/g, "<br>")}`);
    }
}
