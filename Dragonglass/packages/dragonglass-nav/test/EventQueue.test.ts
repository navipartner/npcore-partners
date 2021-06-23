import { StateStore } from "dragonglass-redux";
import { IEventInfo } from "../src/nav/IEventInfo";
import { EventQueue } from "./../src/nav/EventQueue";

describe("EventQueue class", () => {
    test("Instantiation and content", () => {
        const store = {
            dispatch: jest.fn()
        } as unknown as StateStore;

        const eventQueue = new EventQueue(store);

        const event1 = {} as IEventInfo;
        expect(eventQueue.isEmpty()).toBe(true);
        eventQueue.push(event1);
        expect(eventQueue.isEmpty()).toBe(false);
        const event2 = eventQueue.shift();
        expect(eventQueue.isEmpty()).toBe(true);
        expect(event1).toBe(event2);
        expect(store.dispatch).toBeCalledTimes(2);
    });

});