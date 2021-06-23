import { bootstrapFrameworkReady } from "./../src/bootstrap/framework.ready";
import { DEBUG_SEVERITY, GlobalEventDispatcher, GLOBAL_EVENTS, Ready } from "dragonglass-core";
import { NAVManager } from "../src/nav/NAVManager";
import { mockDocument } from "./mock/mock.document";
import { mockNAVFramework } from "./mock/mock.NAVFramework";
import { mockStateStore } from "./mock/mock.StateStore";
import { mockWindow } from "./mock/mock.window";

describe("Bootstrap framework.ready", () => {

    const store = mockStateStore();
    Ready.initialize(mockWindow, mockDocument);
    NAVManager.initialize(store, mockNAVFramework(), "", DEBUG_SEVERITY.WARNING);

    test("framework.ready", async () => {
        const ready = jest.fn();
        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.FRAMEWORK_READY, ready);
        
        // Schedule Ready events in 100ms
        setTimeout(() => mockWindow.load(), 100);

        // Await and test
        await bootstrapFrameworkReady();
        expect(ready).toBeCalledTimes(1);
    });
});
