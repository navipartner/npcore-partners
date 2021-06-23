import { GlobalErrorDispatcher, PropertyBag } from "dragonglass-core";
import { NAVEventFactory, NAVInvoker } from "dragonglass-nav";
import { FrontEndAsyncInterface } from "./FrontEndAsyncInterface";
import { GenericFrontEndAsync } from "./GenericFrontEndAsync";

let noSupport = false;

class Awaiter {
    private static _awaiters: PropertyBag<Awaiter> = {};
    private static _awaiterId: number = 0;

    public id: number;
    public resolved: boolean;
    public callbackReceived: boolean;
    public value: any;
    public error: Error | undefined;

    constructor(public type: string, public context: any, public fulfill: Function, public reject: Function) {
        this.id = ++Awaiter._awaiterId;
        this.type = type;
        this.context = context;
        this.fulfill = fulfill;
        this.reject = reject;
        this.resolved = false;
        this.callbackReceived = false;
        this.value = undefined;
        this.error = undefined;
        Awaiter._awaiters[this.id] = this;
    }

    processCallback() {
        if (noSupport) {
            this.reject({ noSupport: true });
            return;
        }

        this.callbackReceived = true;
        if (!this.resolved) {
            console.warn(`Require couldn't resolve [${JSON.stringify(this.context)}] against NAV. This indicates that the required resource is not available in NAV.`);
            this.reject("Content unresolved in NAV.");
            return;
        }

        if (this.error) {
            console.warn(`Awaiter[${this.type}, ${this.id}] completed with a handled C/AL runtime error: ${this.error}`);
            this.reject(this.error);
            return;
        }

        this.fulfill(this.value);
    }

    static resolve(id: number, value: any, error: Error): void {
        var awaiter = Awaiter._awaiters[id];
        if (!awaiter) {
            GlobalErrorDispatcher.raiseCriticalError(`Attempted to resolve an awaiter with id ${id}, which either has been resolved already, or has never been registered.`);
            return;
        }

        delete Awaiter._awaiters[id];
        awaiter.resolved = true;
        awaiter.value = value;
        if (error)
            awaiter.error = error;
    }
}

export class Require {
    private static _initialized: boolean = false;
    private static _require: NAVInvoker<any>;

    private static _initializeIfNecessary() {
        if (this._initialized)
            return;

        this._initialized = true;

        FrontEndAsyncInterface.register(
            new GenericFrontEndAsync(
                "RequireResponse",
                request => (Awaiter.resolve(request.Content.id, request.Content.value, request.Content.error))), "");

        this._require = NAVEventFactory.method({
            name: "Require",
            noSupport: function () {
                noSupport = true;
                return true;
            }
        });
    }

    static requireResource<T>(type: string, context: any): Promise<T> {
        this._initializeIfNecessary();

        return noSupport
            ? Promise.reject({ noSupport: true })
            : new Promise((fulfill, reject) => {
                console.info(`Requiring ${JSON.stringify(context)}`);
                var awaiter = new Awaiter(type, context, fulfill, reject);
                this._require
                    .raise({ type, context, id: awaiter.id })
                    .then(() => awaiter.processCallback.apply(awaiter));
            });
    }
}
