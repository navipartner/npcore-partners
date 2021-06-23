// TODO: Unit tests needed

import { Require } from "dragonglass-front-end-async";
import { WorkflowRuntimeError } from "../errors/WorkflowRuntimeError";
import { PropertyBag } from "dragonglass-core";
import { AsyncFunction } from "./AsyncFunction";

const requireScript = async (script: string): Promise<string> => {
    try {
        return await Require.requireResource("script", { script: script });
    }
    catch (reason) {
        throw new WorkflowRuntimeError(`[AsyncFunction] Script [${script}] could not be retrieved from the back end due to the following reason: ${reason}`);
    }
}

const wrapWorkflowCode = (code: string): string =>
    `const\n
    $$ = workflow.scope,\n
    $parameters = workflow.scope.parameters,\n 
    $captions = workflow.scope.captions,\n
    $labels = workflow.scope.captions,\n
    $viewWorkflowSetup = workflow.scope.viewWorkflowSetup,\n
    $actionContext = workflow.scope.actionContext,\n
    $metadata = workflow.scope.metadata || {},\n
    $view = workflow.scope.view,\n
    $data = workflow.scope.data,\n
    $context = workflow.context;\n\n${code}`;

const retrieveWorkflowFunctionCode = async (code: string): Promise<string> => {
    if (!code) {
        code = "workflow.respond()";
    } else {
        if (code.match(/js\:/gi))
            code = await requireScript(code.substring(3));
    }

    return  wrapWorkflowCode(code);
};

export class FunctionLibrary {
    private static _functionCache: PropertyBag<Function> = {};

    static async getFunction(name: string, code: string): Promise<Function> {
        let func = this._functionCache[name];
        if (func)
            return func;

        return this._functionCache[name] =
            new AsyncFunction(
                "workflow",
                "popup",
                "runtime",
                "hwc",
                "data",
                await retrieveWorkflowFunctionCode(code));
    }
}
