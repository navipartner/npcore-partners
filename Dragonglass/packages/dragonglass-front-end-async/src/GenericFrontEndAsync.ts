import { FrontEndAsyncRequestHandler } from "./FrontEndAsyncRequestHandler";
import { IFrontEndAsyncRequest } from "./interfaces/IFrontEndAsyncRequest";
import { IFrontEndAsyncRequestHandlerDelegate } from "./interfaces/IFrontEndAsyncRequestHandlerDelegate";

export class GenericFrontEndAsync extends FrontEndAsyncRequestHandler {
    private _name: string;
    private _handler: IFrontEndAsyncRequestHandlerDelegate;

    /**
     * Creates a generic handler for specified request type and with specified handler method.
     * @param name Name of the request type to handle with this generic FrontEndAsync handler.
     * @param handler Function to invoke when the FrontEndAsync request of matching type is received.
     */
    constructor(name: string, handler: IFrontEndAsyncRequestHandlerDelegate) {
        super();

        this._name = name;
        this._handler = handler;
    }

    public get name() {
        return this._name;
    }

    public handle(request: IFrontEndAsyncRequest): any {
        return this._handler.call(this, request);
    }
}
