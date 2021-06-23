import { SingletonViolationError } from "dragonglass-core";
import { FrontEndAsyncHandler } from "../src/FrontEndAsyncHandler";
import { AlreadyRegisteredError } from "../src/errors/AlreadyRegisteredError";
import { GenericFrontEndAsync } from "../src/GenericFrontEndAsync";

describe("FrontEndAsyncHandler class", () => {

    const handler = new FrontEndAsyncHandler();

    test("Attempting to instantiate multiple instances", () => {
        expect(() => {
            const second = new FrontEndAsyncHandler();
        }).toThrowError(SingletonViolationError);
    });

    test("Attempting to register same handler multiple times", () => {
        const request = new GenericFrontEndAsync("_test__", request => ({}));

        handler.register(request, "__test__");
        expect(() => handler.register(request, "__test__")).toThrowError(AlreadyRegisteredError);
    })
});
