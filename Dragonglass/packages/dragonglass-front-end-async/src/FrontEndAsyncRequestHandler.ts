import { IFrontEndAsyncRequest } from "./interfaces/IFrontEndAsyncRequest";

/**
 * Generic class that represents a front-end asynchronous request handler. All request handlers must inherit from this class.
 */
export abstract class FrontEndAsyncRequestHandler {
    private _initialized: boolean = false;

    /**
     * Protected method to be implemented by inheriting classes.
     */
    protected _initialize(): void {
        // Abstract implementations can provide some functionality here
    }

    /**
     * Indicates whether this instance has been initialized.
     */
    public get initialized(): boolean {
        return this._initialized;
    }

    /**
     * Public initialization method to be called exclusively by FrontEndAsync to allow each instance to perform a just-in-time
     * initialization, rather than just-in-case at instantiation time.
     */
    public initialize(): void {
        if (this._initialized)
            return;

        this._initialized = true;
        this._initialize();
    }

    /**
     * Returns the name of the request handler
     */
    public get name(): string {
        return this.constructor.name;
    }

    /**
     * Method that front-end async handler will invoke when a matching request is received from the back end.
     *
     * @param request Contains the entire content of the request as received from the back end
     */
    public abstract handle(request: IFrontEndAsyncRequest): any;
}
