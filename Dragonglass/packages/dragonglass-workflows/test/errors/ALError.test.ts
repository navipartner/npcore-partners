import { CustomDragonglassError } from "dragonglass-core";
import { ALError } from "./../../src/errors/ALError";

describe("ALError class", () => {
    test("Inheritance checking", () => {
        const error = new ALError("__test__");
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });

    test("Instantiation and content", () => {
        const error = new ALError("__test__");

        expect(error.message).toMatch("__test__");
        expect(error.ALError).toBeDefined();
        expect(error.ALError.handled).toBe(false);
        expect(error.ALError.popupShown).toBe(false);
        expect(error.ALError.originalMessage).toBe(null);
        expect(error.ALError.handled).toBe(false);


        error.handle();
        expect(error.ALError.handled).toBe(true);
    });
});