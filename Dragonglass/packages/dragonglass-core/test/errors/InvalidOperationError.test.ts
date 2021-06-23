import { CustomDragonglassError } from "../../src/errors/CustomDragonglassError";
import { InvalidOperationError } from "../../src/errors/InvalidOperationError";

describe("InvalidOperationError class", () => {

    test("Inheritance checking", () => {
        const error = new InvalidOperationError("__name__");
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });

    test("Instantiation and content", () => {
        let error1 = new InvalidOperationError("__name__");
        expect(error1.message).toMatch("__name__");

        let error2 = new InvalidOperationError();
        expect(error2.message).toBeDefined();
    });

});