import { Delegate } from "dragonglass-core";
import { IResolver } from "./../interfaces/IResolver";

/**
 * Class that keeps track of specific events and allows resolving an awaited promise only
 * when the count of active unresolved events reaches zero.
 * For example, it can keep track of open popups and only resolves when all popups are closed.
 */
export class CounterAwaiter {
    #count: number = 0;
    #resolve: Delegate | null = null;
    #resolved: boolean = false;
    #awaitable: boolean = false;

    public get resolved(): boolean {
        return this.#resolved;
    }

    public get awaitable(): boolean {
        return this.#awaitable;
    }

    /**
     * Starts a counted process.
     * 
     * @returns An object containing a resolve method, used to indicate that an awaited process has completed.
     */
    public start(): IResolver {
        this.#count++;
        this.#awaitable = true;
        this.#resolved = false;
        return {
            resolve: (() => {
                if (--this.#count !== 0 || !this.#resolve)
                    return;

                this.#awaitable = false;
                this.#resolved = true;
                this.#resolve();
            }).bind(this)
        }
    }


    /**
     * Awaits on all started processes to complete.
     */
    public async await(): Promise<void> {
        return new Promise<void>((fulfill: Delegate) => {
            if (this.#count === 0) {
                this.#resolved = true;
                this.#awaitable = false;
                fulfill();
            }
            else
                this.#resolve = fulfill;
        });
    }

    constructor() {
        // These two are critical! Since there is no guarantee that they will be always correctly accessed
        // through this instance, binding this is necessary to allow accessing # scope weakmaps.
        this.start = this.start.bind(this);
        this.await = this.await.bind(this);
    }
}
