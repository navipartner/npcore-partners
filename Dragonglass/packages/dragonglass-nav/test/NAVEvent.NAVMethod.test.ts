import { Debug } from "dragonglass-core";
import { StateStore } from "dragonglass-redux";
import { EventCoordinator } from "../src/nav/EventCoordinator";
import { NAVEvent } from "../src/nav/NAVEvent";
import { NAVEventFactory } from "../src/nav/NAVEventFactory";
import { NAVMethod } from "../src/nav/NAVMethod";

describe("NAVEvent and NAVMethod classes", () => {

    NAVEventFactory.initialize({} as EventCoordinator, {} as StateStore, new Debug("test"));
    const event = NAVEventFactory.event("test_event");
    const method = NAVEventFactory.method("test_method");

    test("Inheritance", () => {
        expect(event).toBeInstanceOf(NAVEvent);
        expect(method).toBeInstanceOf(NAVMethod);
        expect(method).toBeInstanceOf(NAVEvent);
        expect(event).not.toBeInstanceOf(NAVMethod);
    });

    test("Default content", () => {
        expect(event.skipIfBusy).toBe(false);
        expect(method.skipIfBusy).toBe(false);
        expect(event.name).toBe("test_event");
        expect(method.name).toBe("OnInvokeMethod");
        expect(event.getLogName()).toBe("test_event");
        expect(method.getLogName()).toBe("OnInvokeMethod.test_method");
        expect(event.rejectDuplicate).toBe(false);
        expect(method.rejectDuplicate).toBe(false);
    });

    test("Custom content", () => {
        const event1 = NAVEventFactory.event({ name: "", skipIfBusy: true, rejectDuplicate: true});
        const event2 = NAVEventFactory.event({ name: "", skipIfBusy: false, rejectDuplicate: false});
        const method1 = NAVEventFactory.method({ name: "", skipIfBusy: true, rejectDuplicate: true});
        const method2 = NAVEventFactory.method({ name: "", skipIfBusy: false, rejectDuplicate: false});
        expect(event1.skipIfBusy).toBe(true);
        expect(event1.rejectDuplicate).toBe(true);
        expect(event2.skipIfBusy).toBe(false);
        expect(event2.rejectDuplicate).toBe(false);
        expect(method1.skipIfBusy).toBe(true);
        expect(method1.rejectDuplicate).toBe(true);
        expect(method2.skipIfBusy).toBe(false);
        expect(method2.rejectDuplicate).toBe(false);
    });

});
