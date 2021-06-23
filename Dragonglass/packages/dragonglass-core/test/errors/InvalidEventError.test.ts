import { CustomDragonglassError } from "../../src/errors/CustomDragonglassError";
import { InvalidEventError } from "../../src/errors/InvalidEventError";

describe("InvalidEventError class", () => {

    test("Inheritance checking", () => {
        const error = new InvalidEventError("__test__");
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });

    test("Instantiation and content", () => {
        const error1 = new InvalidEventError("__test_event__");
        expect(error1.eventName).toBe("__test_event__");
    });

});
