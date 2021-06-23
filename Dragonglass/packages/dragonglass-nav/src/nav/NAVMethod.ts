import { NAVEvent } from "./NAVEvent";
import { NAVInvoker } from "./NAVInvoker";
import { METHOD_EVENT_NAME } from "./EventConstants";
import { INAVEventPayload } from "./INAVEventPayload";
import { INAVMethodDescriptor } from "./INAVMethodDescriptor";
import { StateStore } from "dragonglass-redux";
import { EventCoordinator } from "./EventCoordinator";
import { Debug } from "dragonglass-core";
import { BackEndMethodInvocationAwaiter } from "./BackEndAwaiter";

export class NAVMethod extends NAVEvent implements NAVInvoker<any> {
    private _methodName: string;
    private _awaitResponse?: boolean;
    private _timestamp?: number;
    private _nextAwaiterId?: number;
    private _errorResponseSymbol: Symbol;

    /**
     * Creates an instance of a NavMethod object that raises a OnInvokeMethod event in the back end.
     * @param {*} method Name of the method (String) or method descriptor (Object).
     */
    constructor(methodInfo: INAVMethodDescriptor | string, coordinator: EventCoordinator, stateStore: StateStore, debug: Debug) {
        const method = typeof methodInfo === "string"
            ? { name: methodInfo } as INAVMethodDescriptor
            : methodInfo;

        const methodName = method.name;
        method.name = METHOD_EVENT_NAME;
        super(method, coordinator, stateStore, debug);

        this._methodName = methodName;
        this._awaitResponse = method.awaitResponse || false;
        this._timestamp = Date.now();
        this._nextAwaiterId = 0;
        this._errorResponseSymbol = Symbol();

        if (method.processArguments)
            this.registerBeforeInvokePayloadReducer(method.processArguments, "methodPreprocessor");

        if (method.callback)
            this.registerAfterInvokeCallbacks(method.callback, "methodCallback");

    }

    public preProcessPayloadBeforeInvoke(payload: INAVEventPayload): INAVEventPayload {
        return (payload[1] = super.preProcessPayloadBeforeInvoke(payload[1]), payload);
    }

    public postInvokeCallback(payload: INAVEventPayload): void {
        super.postInvokeCallback(payload[1]);
    }

    public getLogName(): string {
        return `${super.getLogName()}.${this._methodName}`;
    }

    public isError(response: Symbol) {
        return response === this._errorResponseSymbol;
    }

    private _getNextAwaitedInvocationId(): string {
        return `${this._timestamp!}-${this._nextAwaiterId!++}`;
    }

    public async raise(payload?: any): Promise<any> {
        payload = payload === undefined ? {} : payload;

        if (this._awaitResponse) {
            const invocationId = this._getNextAwaitedInvocationId();
            const awaitResponse = BackEndMethodInvocationAwaiter.await<any>(invocationId);
            await super.raise([this._methodName, { _dragonglassResponseContext: { invocationId, method: this._methodName }, ...payload }]);
            const response = await awaitResponse;
            return response._dragonglassInvocationError
                ? this._errorResponseSymbol
                : response;
        }

        return await super.raise([this._methodName, payload]);
    }
}
