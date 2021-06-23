import { CustomDragonglassError } from "dragonglass-core";
import { WorkflowRuntimeError } from "../../src/errors/WorkflowRuntimeError";

describe("ALError class", () => {
    test("Inheritance checking", () => {
        const error = new WorkflowRuntimeError("__test__");
        expect(error).toBeInstanceOf(CustomDragonglassError);
    });
});