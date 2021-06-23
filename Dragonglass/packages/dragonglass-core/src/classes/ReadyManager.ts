import { InvalidOperationError } from "../errors/InvalidOperationError";
import { Delegate } from "../interfaces/Delegates";
import { IAddEventListener } from "../interfaces/IAddEventListener";
import { IReadyState } from "../interfaces/IReadyState";

let initialized = false;
let instance: ReadyManager;
const INSTANTIATION_TOKEN = Symbol();

class ReadyManager {
    private _isReady: boolean;
    private _subscribers: Delegate[];

    constructor(window: IAddEventListener, document: IReadyState, instantiationToken: Symbol = Symbol()) {
        if (instantiationToken !== INSTANTIATION_TOKEN)
            throw new InvalidOperationError("An attempt was made to instantiate ReadyManager directly. Call Ready.instance instead.");

        this._isReady = document.readyState === "complete";
        this._subscribers = [];

        if (this._isReady)
            return;

        window.addEventListener("load", () => {
            this._isReady = true;

            for (let subscriber of this._subscribers)
                subscriber();
        });
    }

    run(subscriber: Delegate): void {
        if (this._isReady) {
            subscriber();
            return;
        }

        this._subscribers.push(subscriber);
    }

    get isReady(): boolean {
        return this._isReady;
    }

    static initialize(window: IAddEventListener, document: IReadyState): void {
        if (initialized)
            throw new InvalidOperationError("Attempting to initialize ReadyManager that has been already initialized.");

        initialized = true;
        instance = new ReadyManager(window, document, INSTANTIATION_TOKEN);
    }

    static get instance() {
        if (!initialized)
            throw new InvalidOperationError("Attempting to access instance of ReadyManager that has not been previously initialized.");

        return instance;
    }
}

export const Ready = ReadyManager;
