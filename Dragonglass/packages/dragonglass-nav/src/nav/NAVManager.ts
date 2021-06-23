import { Delegate_T } from "dragonglass-core";
import { Debug, DEBUG_SEVERITY } from "dragonglass-core";
import { INAVEnvironment } from "./INAVEnvironment";
import { Ready } from "dragonglass-core";
import { INAVFramework } from "./INAVFramework";
import { IDebugSeverity } from "dragonglass-core";
import { EventDispatcher } from "dragonglass-core";
import { InvalidOperationError } from "dragonglass-core";
import { StateStore } from "dragonglass-redux";
import { NAVEventFactory } from "./NAVEventFactory";
import { EventCoordinator } from "./EventCoordinator";
import { reducer } from "../redux/nav-reducer";

const dummyEnvironment = {} as INAVEnvironment;
const BUSY_CHANGED = "BUSY_CHANGED";
const INSTANTIATION_TOKEN = Symbol();

let initialized = false;
let instance: NAVManager;

const normalizePath = (path: string): string => {
    path = path.endsWith("/") || path.endsWith("\\")
        ? path.substring(0, path.length - 1)
        : path;
    if (path.startsWith("/") || path.startsWith("\\"))
        path = path.substring(1);
    return path;
};

export class NAVManager {
    private _environment: INAVEnvironment = dummyEnvironment;
    private _nav: INAVFramework;
    private _debug: Debug;
    private _dispatcher: EventDispatcher;
    private _path: string;
    private _ready: boolean = false;

    constructor(nav: INAVFramework, path: string, logLevel: IDebugSeverity, instantiationToken: Symbol = Symbol()) {
        if (instantiationToken !== INSTANTIATION_TOKEN)
            throw new InvalidOperationError("An attempt was made to instantiate NAVManager directly. Call NAV.instance instead.");

        this._nav = nav;
        this._debug = new Debug("NAV.Interface", logLevel);
        this._dispatcher = new EventDispatcher([BUSY_CHANGED]);
        this._path = normalizePath(path);

        Ready.instance.run(() => {
            this._ready = true;
            this._environment = nav.GetEnvironment();
            this._environment.OnBusyChanged = () => {
                this._debug.log(this._environment.Busy ? "Busy" : "Idle");
                this._dispatcher.raise(BUSY_CHANGED, this._environment.Busy);
            }
        });
    }

    get busy() {
        return this._ready && this._environment.Busy;
    }

    subscribeBusyChanged(handler: Delegate_T<boolean>): void {
        if (!this._dispatcher.addEventListener(BUSY_CHANGED, handler))
            this._debug.bug("The handler you are trying to subscribe to the busy state change is already subscribed", DEBUG_SEVERITY.WARNING);
    }

    unsubscribeBusyChanged(handler: Delegate_T<boolean>): void {
        if (!this._dispatcher.removeEventListener(BUSY_CHANGED, handler))
            this._debug.bug("The handler you are trying to unsubscribe from the busy state change is not subscribed", DEBUG_SEVERITY.WARNING)
    }

    mapPath(resource: string): string {
        return this._nav.GetImageResource(`${this._path}/${resource}`);
    }

    setPath(newPath: string): void {
        this._path = normalizePath(newPath);
    }

    invokeBackEnd(method: string, args: any[], skipIfBusy: boolean, callback: Function): void {
        this._nav.InvokeExtensibilityMethod(method, args, skipIfBusy, callback);
    }

    static initialize(stateStore: StateStore, nav: INAVFramework, path: string, logLevel: IDebugSeverity): void {
        if (initialized)
            throw new InvalidOperationError("Attempting to initialize NAVManager that has been already initialized.");

        initialized = true;
        instance = new NAVManager(nav, path, logLevel, INSTANTIATION_TOKEN);

        stateStore.injectReducer("navEvents", reducer);
        EventCoordinator.initialize(instance, stateStore, instance._debug);
        NAVEventFactory.initialize(EventCoordinator.instance, stateStore, instance._debug);

    }

    static get instance() {
        if (!initialized)
            throw new InvalidOperationError("Attempting to access instance of NAVManager that has not been previously initialized.");

        return instance;
    }
}

export const NAV = NAVManager;