import { Ready } from "./../../src/classes/ReadyManager";

// IMPORTANT!
//
// Split into parts, because:
// * import syntax is not affected by jest.resetModules(), thus Ready state remains "dirty" even after jest.resetModules()
// * using require() syntax instead of import causes type information on Ready constant to be lost, invalidating the purpose of TypeScript


/*
 * Simulates a normal flow of window loading where document ready state is not "complete" and window "load" event
 * hasn't fired yet.
 */
describe("ReadyManager class (part 2)", () => {

    test("Simulating normal loading flow", () => {

        const mockWindow = {
            _listener: (() => { }) as Function,
            addEventListener: jest.fn((event: string, listener: Function) => {
                expect(event).toBe("load");
                mockWindow._listener = listener;
            }),
            load: () => mockWindow._listener()
        };
        const mockDocument = { readyState: "loading" };

        Ready.initialize(mockWindow, mockDocument);

        const subscriberBeforeReady = jest.fn();
        const subscriberAfterReady = jest.fn();

        // Making sure that page is false
        expect(Ready.instance.isReady).toBe(false);

        // Scheduling a function to run when page is ready
        Ready.instance.run(subscriberBeforeReady);

        // ... and making sure none of the scheduled subscriber is invoked, because page is not ready yet
        expect(subscriberBeforeReady).not.toBeCalled();
        expect(subscriberAfterReady).not.toBeCalled();

        // Triggering the window "load" event, and this immediately calls the first subscriber
        mockWindow.load();
        expect(subscriberBeforeReady).toBeCalled();
        expect(mockWindow.addEventListener)
        
        // Also, it turns the ready state on
        expect(Ready.instance.isReady).toBe(true);

        // "Scheduling" a second subscriber, that one fires immediately because page is ready
        Ready.instance.run(subscriberAfterReady);
        expect(subscriberAfterReady).toBeCalled();

        // Even though it should be obvious from the flow above, let's make sure that...
        expect(mockWindow.addEventListener).toBeCalledTimes(1);
    });

});