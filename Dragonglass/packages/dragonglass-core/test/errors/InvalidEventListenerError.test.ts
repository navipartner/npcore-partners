import { CustomDragonglassError } from "../../src/errors/CustomDragonglassError";
import { InvalidEventListenerError } from "../../src/errors/InvalidEventListenerError";

describe("InvalidEventListenerError class", () => {

    test("Inheritance checking", () => {
        const error = new InvalidEventListenerError("__test_event__");
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });

    test("Instantiation and content", () => {
        const error1 = new InvalidEventListenerError("__test_event__");
        expect(error1.eventName).toBe("__test_event__");
    });

});