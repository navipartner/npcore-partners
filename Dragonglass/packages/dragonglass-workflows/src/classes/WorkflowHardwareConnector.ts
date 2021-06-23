// TODO: Unit tests needed!

import { WorkflowRuntimeError } from "./../errors/WorkflowRuntimeError";
import { IHardwareConnector } from "../interfaces/IHardwareConnector";

const getHardwareConnectorError = (handler: string) => new WorkflowRuntimeError(`Handler '${handler}' is invoked on a Hardware Connector instance that has not been initialized.`);

export const HARDWARE_DISPOSE_TOKEN = Symbol();

export class WorkflowHardwareConnector {
    #initialized: boolean;
    #handlers: string[];
    #connector: IHardwareConnector;

    constructor(connector: IHardwareConnector) {
        this.#initialized = typeof connector === "object" && !!connector;
        this.#handlers = [];
        this.#connector = connector;
    }

    /**
     * Disposes of the current WorkflowHardwareConnector at the end of execution of a workflow. This cleans up any global state that may have been modified by the UI.
     * (for now, it's only the timeout state)
     *
     * @param {Symbol} disposeToken A control variable that should be used to let this instance know that the __dispose__ code is valid. This prevents curious
     * wannabe hackers writing workflow code to dispose of Hardware Connector just to see what happens.
     */
    __dispose__(disposeToken: Symbol) {
        if (disposeToken !== HARDWARE_DISPOSE_TOKEN)
            return;

        this.#handlers.forEach(handler => this.#connector.unregisterResponseHandler(handler));
    }
    /**
     * Invokes Hardware Connector on the specified handler.
     * @param {String} handler Name of the handler to invoke.
     * @param {Object} content Content object to pass to the handler. Contains anything that handler can work with.
     * @param {String} context Context ID of the registered response handler. If not present, no response handler will be invoked.
     * @returns {Object} Returns any value returned from the call to Hardware Connector.
     */
    async invoke(handler: string, content: any, context: string): Promise<any> {
        if (!this.#initialized)
            throw getHardwareConnectorError(handler);

        return await (
            context
                ? this.#connector.sendRequestAsync(handler, content, context)
                : this.#connector.sendRequestAndWaitForResponseAsync(handler, content)
        );
    }

    /**
     * Registers a response handler with Hardware Connector
     * @param {Function} callback Callback to invoke when Hardware Connector completes a request.
     */
    registerResponseHandler(callback: (any: any) => {}): string {
        const contextId = this.#connector.registerResponseHandler(callback);
        this.#handlers.push(contextId);
        return contextId;
    }

    /**
     * Unregisters a handler based on the context ID.
     * @param {String} context Context ID for handler to unregister.
     */
    unregisterResponseHandler(context: string): void {
        this.#connector.unregisterResponseHandler(context);
    }
}
