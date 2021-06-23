import { Singleton } from "dragonglass-core";
import { ITranscendence } from "dragonglass-transcendence";
import { FALLBACK_TO_TRANSCENDENCE } from "./Constants";
import { AlreadyRegisteredError } from "./errors/AlreadyRegisteredError";
import { InvalidRequestError } from "./errors/InvalidRequestError";
import { FrontEndAsyncRequestHandler } from "./FrontEndAsyncRequestHandler";
import { IFrontEndAsyncRequest } from "./interfaces/IFrontEndAsyncRequest";

export class FrontEndAsyncHandler extends Singleton {
    private _registry: Record<string, FrontEndAsyncRequestHandler> = {};
    private _transcendence: ITranscendence | null = null;

    public handleRequest(request: IFrontEndAsyncRequest) {
        console.log(`InvokeFrontEndAsync request received: ${request.Method || "(invalid)"} `);

        if (!request.Method || typeof request.Method !== "string")
            throw new InvalidRequestError("Request is missing the Method property");

        let fallbackToTranscendence = this._transcendence !== null;
        if (this._registry[request.Method]) {
            let handler = this._registry[request.Method];

            if (!handler.initialized)
                handler.initialize();
                
            let handleResult: any = handler.handle(request);
            if (handleResult !== FALLBACK_TO_TRANSCENDENCE) // Explicit fallback to Transcendence (e.g. for Workflows "1.0" fallback from Workflows "2.0" handler)
                return handleResult;
            fallbackToTranscendence = true;
        }

        if (!fallbackToTranscendence || this._transcendence === null)
            throw new InvalidRequestError(`No request handler found for "${request.Method}"`);

        console.info(`Falling back to Transcendence for handling the "${request.Method}" request.`);
        let transcendenceResult = this._transcendence.invokeFrontEndAsync(request);
        if (!transcendenceResult)
            throw new InvalidRequestError(`No request handler found for "${request.Method}"`);

        return transcendenceResult;
    }

    /**
     * Registers a FrontEndAsync handler to handle specific InvokeFrontEndAsync requests from the back end.
     * @param {FrontEndAsyncRequest} handler An instance of a FrontEndAsync handler to register with the FrontEndAsync interface
     * @param {String} name (Optional) Name of the FrontEndAsync to register. If omitted, the class name will be used instead.
     */
    public register(handler: FrontEndAsyncRequestHandler, name?: string) {
        const handlerName: string = name || handler.name;
        if (this._registry[handlerName])
            throw new AlreadyRegisteredError(handlerName);

        this._registry[handlerName] = handler;
    }

    /**
     * Initializes the InvokeFrontEndAsync interface for the back end.
     * @param target Any object onto which the InvokeFrontEndAsync method will be appended. At runtime, this is "window"; at test this is any mock.
     * @param transcendence Transcendence instance that will be used as fallback for request handling
     */
    public initialize(target: any, transcendence: ITranscendence | null = null) {
        if (transcendence)
            this._transcendence = transcendence;

        if (target) {
            if (target.InvokeFrontEndAsync)
                delete target.InvokeFrontEndAsync;
                
            console.log("Initializing the InvokeFrontEndAsync interface");
            Object.defineProperty(target, "InvokeFrontEndAsync", { value: (request: IFrontEndAsyncRequest) => this.handleRequest(request) });
        }
    }
}
