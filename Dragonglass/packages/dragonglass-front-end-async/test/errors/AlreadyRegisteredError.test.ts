import { CustomDragonglassError } from "dragonglass-core";
import { AlreadyRegisteredError } from "../../src/errors/AlreadyRegisteredError";

describe("AlreadyRegisteredError class", () => {

    test("Inheritance checking", () => {
        const error = new AlreadyRegisteredError("__jest_test__");
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });

    test("Instantiation and base functionality", () => {
        let error1 = new AlreadyRegisteredError("__jest_test__");
        expect(error1.message).toMatch("__jest_test__");
        expect(error1.name).toBe("AlreadyRegisteredError");
    });
    
});
