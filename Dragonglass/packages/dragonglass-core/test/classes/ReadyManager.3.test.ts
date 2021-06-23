import { Ready } from "./../../src/classes/ReadyManager";

// IMPORTANT!
//
// Split into parts, because:
// * import syntax is not affected by jest.resetModules(), thus Ready state remains "dirty" even after jest.resetModules()
// * using require() syntax instead of import causes type information on Ready constant to be lost, invalidating the purpose of TypeScript


/*
 * Simulates a slightly unlikely flow where page has been loaded already (ready state is "complete") so "load" event will never fire.
 * Each subscriber should run immediately on Ready.run.
 * Even though this flow is very unlikely, race conditions can be expected at page loading flow from BC, and this can indeed happen.
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
        const mockDocument = { readyState: "complete" };

        Ready.initialize(mockWindow, mockDocument);

        const subscriberBeforeReady = jest.fn();
        const subscriberAfterReady = jest.fn();

        // Making sure that page is ready
        expect(Ready.instance.isReady).toBe(true);
        
        // Scheduling a function to run when page is ready, and it triggers immediately
        Ready.instance.run(subscriberBeforeReady);
        expect(subscriberBeforeReady).toBeCalled();

        // Scheduling a second subscriber, should fire immediately, too
        Ready.instance.run(subscriberAfterReady);
        expect(subscriberAfterReady).toBeCalled();

        // When this flow occurs, the window "load" listener should have never been run!
        expect(mockWindow.addEventListener).not.toBeCalled();
    });

});