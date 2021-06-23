import { InvalidOperationError } from "../../src/errors/InvalidOperationError";
import { Ready } from "../../src/classes/ReadyManager";

// IMPORTANT!
//
// Split into parts, because:
// * import syntax is not affected by jest.resetModules(), thus Ready state remains "dirty" even after jest.resetModules()
// * using require() syntax instead of import causes type information on Ready constant to be lost, invalidating the purpose of TypeScript


describe("ReadyManager class", () => {

    beforeEach(() => jest.resetModules());

    const mockSimple = {
        window: { addEventListener: () => { } },
        document: { readyState: "" }
    };

    test("Attempting to instantiate directly", () => {
        let ready: any;
        expect(() => ready = new Ready(mockSimple.window, mockSimple.document)).toThrowError(InvalidOperationError);
        expect(ready).toBeUndefined();
    });

    test("Initialization and reinitialization", () => {
        // Failing when Ready has not been initialized
        expect(() => Ready.instance.run(() => { })).toThrowError(InvalidOperationError);

        Ready.initialize(mockSimple.window, mockSimple.document);
        expect(() => Ready.initialize(mockSimple.window, mockSimple.document)).toThrowError(InvalidOperationError);
    });
    
});