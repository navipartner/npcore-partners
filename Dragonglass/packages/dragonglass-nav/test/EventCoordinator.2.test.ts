import { DEBUG_SEVERITY, Ready } from "dragonglass-core";
import { INVOCATION_FAILED, INVOCATION_SUCCESSFUL, REJECTED_DUPLICATE, SKIPPED_BUSY } from "../src/nav/EventConstants";
import { NAVEventFactory } from "../src/nav/NAVEventFactory";
import { NAVManager } from "../src/nav/NAVManager";
import { mockDocument } from "./mock/mock.document";
import { mockNAVFramework, MOCK_NAV_THROW_ERROR } from "./mock/mock.NAVFramework";
import { mockStateStore } from "./mock/mock.StateStore";
import { mockWindow } from "./mock/mock.window";

describe("EventCoordinator class", () => {

    const store = mockStateStore();
    Ready.initialize(mockWindow, mockDocument);
    NAVManager.initialize(store, mockNAVFramework(), "", DEBUG_SEVERITY.WARNING);

    test("Scheduling events after Ready fires", async () => {
        const event = NAVEventFactory.event("test");
        let ready = false;
        let called = false;

        // Scheduling ready flag to be set when "page" is loaded
        Ready.instance.run(() => ready = true);
        expect(ready).toBe(false);

        // Setting up event invocation promise
        const promise = new Promise(fulfill => event.raise([]).then(fulfill));

        // Load page after 1 second
        setTimeout(() => {
            mockWindow.load();
            expect(ready).toBe(true);
        }, 1000);
        expect(ready).toBe(false);

        // Flag event as loaded when event promise resolves
        promise.then(() => called = true);
        expect(called).toBe(false); // At this moment, we are still awaiting, called is still false

        // Let's measure some time
        let time = Date.now();
        await promise;

        // Called is now true, and at least 1 second has passed
        expect(called).toBe(true);
        expect(Date.now() - time).toBeGreaterThanOrEqual(1000);
    });

    test("Events with SkipIfBusy", async () => {
        const event = NAVEventFactory.event({ name: "test", skipIfBusy: true });

        let result1: string = "";
        let result2: string = "";
        const promises = [
            event.raise([]).then(r => result1 = r),
            event.raise([]).then(r => result2 = r)
        ];
        await Promise.all(promises);
        expect(result1).toBe(INVOCATION_SUCCESSFUL);
        expect(result2).toBe(SKIPPED_BUSY);
    });


    test("Event invocation ends in failure", async () => {
        const event = NAVEventFactory.event("errorEvent");
        const result = await event.raise([MOCK_NAV_THROW_ERROR]);
        expect(result).toBe(INVOCATION_FAILED);
    });

    test("Events with RejectDuplicate", async () => {
        const event = NAVEventFactory.event({ name: "test", rejectDuplicate: true });

        let result1: string = "";
        let result2: string = "";
        const promises = [
            event.raise([]).then(r => result1 = r),
            event.raise([]).then(r => result2 = r)
        ];
        await Promise.all(promises);
        expect(result1).toBe(INVOCATION_SUCCESSFUL);
        expect(result2).toBe(REJECTED_DUPLICATE);
    });

    test("Events with normal default flow", async () => {
        const event = NAVEventFactory.event("test");

        const results: string[] = [];
        const promises: Promise<string>[] = [];
        for (let i = 0; i < 5; i++) {
            let promise = event.raise([]);
            promise.then(r => results.push(r));
            promises.push(promise);
        }
        await Promise.all(promises);
        for (let i = 0; i < 5; i++)
            expect(results[i]).toBe(INVOCATION_SUCCESSFUL);
    });

    test("Invoking 'sensitive' events in sequence", async () => {
        const event = NAVEventFactory.event({ name: "test", skipIfBusy: true, rejectDuplicate: true });

        for (let i = 0; i < 5; i++) {
            const result = await event.raise([i]);
            expect(result).toBe(INVOCATION_SUCCESSFUL);
        }
    });

    test("Events that append data states to content", async () => {
        const event = NAVEventFactory.event({ name: "test", appendDataStates: true });
        await event.raise([]);
        expect(store.appendDataStatesToTarget).toBeCalledTimes(1);
    });

    test("Events without arguments", async () => {
        mockWindow.load();
        const event = NAVEventFactory.event("test");
        const result = await event.raise();
        expect(result).toBe(INVOCATION_SUCCESSFUL);
    });

    test("Methods with arguments", async () => {
        const method = NAVEventFactory.method("test");
        const result = await method.raise(1);
        expect(result).toBe(INVOCATION_SUCCESSFUL);
    });

    test("Methods without arguments", async () => {
        const method = NAVEventFactory.method("test");
        const result = await method.raise();
        expect(result).toBe(INVOCATION_SUCCESSFUL);
    });

    test("Methods with processArguments", async () => {
        const processArguments = jest.fn();
        const method = NAVEventFactory.method({name: "method", processArguments });
        await method.raise();
        expect(processArguments).toBeCalledTimes(1);
    });

    test("Methods with invalid processArguments", async () => {
        const method = NAVEventFactory.method({name: "method", processArguments: "_no_error_should_happen" as unknown as Function }); // Won't happen in TypeScript, but JavaScript could call this, too
        await method.raise();
    });

    test("Methods with callback", async () => {
        const callback = jest.fn();
        const method = NAVEventFactory.method({name: "method", callback });
        await method.raise();
        expect(callback).toBeCalledTimes(1);
    });

    test("Methods with invalid callback", async () => {
        const method = NAVEventFactory.method({name: "method", callback: "_no_error_should_happen" as unknown as Function }); // Won't happen in TypeScript, but JavaScript could call this, too
        await method.raise();
    });

});
