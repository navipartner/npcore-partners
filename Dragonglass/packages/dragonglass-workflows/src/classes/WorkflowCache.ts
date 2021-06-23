import { GlobalErrorDispatcher, PropertyBag } from "dragonglass-core";
import { ActionDescription } from "./ActionDescription";
import { Require } from "dragonglass-front-end-async";

const workflowCache: PropertyBag<ActionDescription> = {};

export class WorkflowCache {
    static retrieveWorkflow(action: string): Promise<ActionDescription> {
        return new Promise((fulfill, reject) => {
            if (typeof workflowCache[action] === "object") {
                fulfill(workflowCache[action]);
                return;
            };
    
            Require.requireResource<ActionDescription>("action", { action: action }).then(
                value => {
                    if (value.Workflow.Content.engineVersion !== "2.0") {
                        GlobalErrorDispatcher.raiseCriticalError("Attempting to run a workflow v.1 from a v.2 nested required context.");
                        reject();
                        return;
                    }
    
                    fulfill(workflowCache[action] = value);
                },
                value => {
                    const error = value
                        ? (
                            value.noSupport
                                ? "Attempting to run or queue another workflow without back-end support for the Require method.\nYou must upgrade your back end to NPR 5.50."
                                : `Require failed with the following message: ${String(value)}`
                        )
                        : "Require failed without a reason given.";
                    GlobalErrorDispatcher.raiseCriticalError(error);
                    reject();
                });
        });
    }    
}
