import { Debug, InvalidOperationError } from "dragonglass-core";
import { INAVEventDescriptor } from "./INAVEventDescriptor";
import { NAVEvent } from "./NAVEvent";
import { INAVMethodDescriptor } from "./INAVMethodDescriptor";
import { NAVMethod } from "./NAVMethod";
import { StateStore } from "dragonglass-redux";
import { EventCoordinator } from "./EventCoordinator";

export class NAVEventFactory {
    private static _initialized: boolean;
    private static _coordinator: EventCoordinator;
    private static _stateStore: StateStore;
    private static _debug: Debug;

    static initialize(coordinator: EventCoordinator, stateStore: StateStore, debug: Debug) {
        if (this._initialized)
            throw new InvalidOperationError("An attempt was made to re-initialize NAVEventFactory. It can only be initialized once.");

        this._initialized = true;
        this._coordinator = coordinator;
        this._stateStore = stateStore;
        this._debug = debug;
    }

    static event(eventInfo: INAVEventDescriptor | string): NAVEvent{
        this._debug?.info(`Invoking ${this.constructor.name}.event`);
        if (!this._initialized)
            throw new InvalidOperationError("An attempt was made to create a new NAVEvent before NAVEventFactory was initialized. Call initialize first.");
        return new NAVEvent(eventInfo, this._coordinator, this._stateStore, this._debug);
    }

    static method(methodInfo: INAVMethodDescriptor | string): NAVMethod {
        this._debug?.info(`Invoking ${this.constructor.name}.method`);
        if (!this._initialized)
            throw new InvalidOperationError("An attempt was made to create a new NAVMethod before NAVEventFactory was initialized. Call initialize first.");
        return new NAVMethod(methodInfo, this._coordinator, this._stateStore, this._debug);
    }
}
