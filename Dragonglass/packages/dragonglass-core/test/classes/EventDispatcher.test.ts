import { InvalidEventListenerError } from "../../src/errors/InvalidEventListenerError";
import { EventDispatcher } from "../../src/classes/EventDispatcher";
import { InvalidEventError } from "../../src/errors/InvalidEventError";

describe("EventDispatcher class", () => {
    const dispatcher = new EventDispatcher(["__test1__", "__test2__", "__test3__", "__test4__"]);

    test("Adding/removing an invalid listener", () => {
        expect(() => {
            dispatcher.addEventListener("__test_unknown__", () => { });
        }).toThrowError(InvalidEventListenerError);

        expect(() => {
            dispatcher.removeEventListener("__test_unknown__", () => { });
        }).toThrowError(InvalidEventListenerError);
    });

    test("Adding the same listener twice", () => {
        const listener = () => {};

        expect(dispatcher.addEventListener("__test1__", listener)).toBe(true);
        expect(dispatcher.addEventListener("__test1__", listener)).toBe(false);
    });

    test("Removing non-registered listener", () => {
        expect(dispatcher.removeEventListener("__test1__", () => {})).toBe(false);
    });

    test("Removing a listener for an event that has never been subscribed to", () => {
        expect(dispatcher.removeEventListener("__test4__", () => {})).toBe(false);
    });

    test("Raising an unregistered event", () => {
        expect(() => dispatcher.raise("__test_unknown__")).toThrowError(InvalidEventError);
    })
    test("Raising events", () => {
        let listenerCalled = 0;
        const listener = () => listenerCalled++;

        dispatcher.addEventListener("__test1__", listener);
        dispatcher.raise("__test1__");
        dispatcher.removeEventListener("__test1__", listener);
        dispatcher.raise("__test1__");

        expect(listenerCalled).toBe(1);
    });

    test("Raising events with arguments", () => {
        const listener = (arg1: number, arg2: number) => {
            switch (arg1) {
                case 1:
                    expect(arg2).toBeUndefined();
                    break;
                case 2:
                    expect(arg2).toBe(2);
                    break;
            }
        };

        dispatcher.addEventListener("__test1__", listener);
        dispatcher.raise("__test1__", 1);
        dispatcher.raise("__test1__", 2, 2);
        dispatcher.removeEventListener("__test1__", listener);
    });

    test("Raising events with owner", () => {
        const owner1 = {};
        const owner2 = {};

        let listener1Called: number = 0;
        let listener2Called: number = 0;

        const listener1 = () => listener1Called++;
        const listener2 = () => listener2Called++;

        dispatcher.addEventListener("__test1__", listener1, owner1);
        dispatcher.addEventListener("__test1__", listener2, owner2);

        dispatcher.raise("__test1__");
        dispatcher.removeEventListenersByOwner(owner1);
        dispatcher.raise("__test1__");
        dispatcher.removeEventListenersByOwner(owner2);
        dispatcher.raise("__test1__");

        expect(listener1Called).toBe(1);
        expect(listener2Called).toBe(2);
    });

    test("Testing dispatcher without events", () => {
        dispatcher.raise("__test3__");
    });

    test ("Testing supportedEvents property", () => {
        const events = ["_e1", "_e2", "_e3"];

        const dispatcher = new EventDispatcher(events);
        
        expect(dispatcher.supportedEvents.includes("_e1")).toBe(true);
        expect(dispatcher.supportedEvents.includes("_e2")).toBe(true);
        expect(dispatcher.supportedEvents.includes("_e3")).toBe(true);
        expect(dispatcher.supportedEvents.includes("_e4")).toBe(false);

        dispatcher.supportedEvents.push("_e4");
        expect(dispatcher.supportedEvents.includes("_e4")).toBe(false); // Still false, cannot add to this array

        expect(dispatcher.supportedEvents === events).toBe(false);

        const supported1 = dispatcher.supportedEvents;
        const supported2 = dispatcher.supportedEvents;
        expect(supported1 !== supported2).toBe(true);
    });

    test("Testing multiple arguments", () => {
        const dispatcher = new EventDispatcher(["_e1", "_e2", "_e3"]);

        dispatcher.addEventListener("_e1", (e1, e2, e3) => {
            expect(e1).toBe(1);
            expect(e2).toBeUndefined();
            expect(e3).toBeUndefined();
        });
        dispatcher.addEventListener("_e2", (e1, e2, e3) => {
            expect(e1).toBe(1);
            expect(e2).toBe(2);
            expect(e3).toBeUndefined();
        });
        dispatcher.addEventListener("_e3", (e1, e2, e3) => {
            expect(e1).toBe(1);
            expect(e2).toBe(2);
            expect(e3).toBe(3);
        });

        dispatcher.raise("_e1", 1);
        dispatcher.raise("_e2", 1, 2);
        dispatcher.raise("_e3", 1, 2, 3);
    });
});
