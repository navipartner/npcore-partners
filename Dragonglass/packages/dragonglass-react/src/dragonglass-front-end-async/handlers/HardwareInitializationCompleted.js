import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { NAVEventFactory } from "dragonglass-nav";

// TODO: This entire module seems unnecessary - AL is invoking JavaScript so that JavaScript could invoke AL? Fix this mess!

export class HardwareInitializationCompleted extends FrontEndAsyncRequestHandler {
    _initialize() {
        this._initializationComplete = NAVEventFactory.method("InitializationComplete");
    }

    async handle() {
        await this._initializationComplete.raise();
        console.log("Completed back-end session initialization.");
    }
}
