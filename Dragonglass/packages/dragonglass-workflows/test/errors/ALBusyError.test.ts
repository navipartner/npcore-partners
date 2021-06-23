import { ALBusyError } from "./../../src/errors/ALBusyError";
import { CustomDragonglassError } from "dragonglass-core";

describe("ALError class", () => {
    test("Inheritance checking", () => {
        const error = new ALBusyError();
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });
});