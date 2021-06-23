import { GlobalErrorDispatcher } from "dragonglass-core";
import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { ReactInterface } from "../../classes/ReactInterface";

export class RegisterModule extends FrontEndAsyncRequestHandler {
    handle(request) {
        if (request.Content.Script) {
            try {
                var func = new Function("n$", request.Content.Script);
                func(ReactInterface.transcendence);
            } catch (e) {
                GlobalErrorDispatcher.raiseCriticalError(`[RegisterModule] Failed registering a module: ${e.message}`);
            };
        };
    }
}
