import { CustomDragonglassError } from "../../src/errors/CustomDragonglassError";
import { SingletonViolationError } from "../../src/errors/SingletonViolationError";

describe("SingletonViolationError class", () => {

    test("Inheritance checking", () => {
        const error = new SingletonViolationError("__name__");
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });

    test("Instantiation and content", () => {
        let error1 = new SingletonViolationError("__name__");
        expect(error1.message).toMatch("__name__");
        expect(error1.className).toBe("__name__");
    });

});