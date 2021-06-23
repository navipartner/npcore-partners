import { GenericFrontEndAsync } from "./../src/GenericFrontEndAsync";
import { FrontEndAsyncInterface } from "./../src/FrontEndAsyncInterface";
import { IFrontEndAsyncRequest } from "./../src/interfaces/IFrontEndAsyncRequest";
import { ITranscendence } from "dragonglass-transcendence";
import { getTranscendenceInstance } from "dragonglass-transcendence";
import { InvalidRequestError } from "../src/errors/InvalidRequestError";
import { FALLBACK_TO_TRANSCENDENCE } from "../src/Constants";
import { FrontEndAsyncRequestHandler } from "../src/FrontEndAsyncRequestHandler";

describe("FrontEndAsyncInterface tests", () => {

    test("Testing with invalid request", () => {
        const window = { InvokeFrontEndAsync: (_: any) => { } };
        FrontEndAsyncInterface.initialize(window, null);

        expect(() => window.InvokeFrontEndAsync({})).toThrowError(InvalidRequestError);
    });

    test("Testing without fallback to Transcendence", () => {
        const window = { InvokeFrontEndAsync: (_: any) => { } };
        FrontEndAsyncInterface.initialize(window, null);

        let requested1 = false;
        let requested2 = false;

        const requestHandler1 = new GenericFrontEndAsync("__test1__", request => requested1 = request.Method === "__test1__");
        FrontEndAsyncInterface.register(requestHandler1, "__test1__");

        expect(requested1).toBe(false);
        window.InvokeFrontEndAsync({ Method: "__test1__" });
        expect(requested1).toBe(true);

        expect(() => window.InvokeFrontEndAsync({ Method: "__test2__" })).toThrow();

        const requestHandler2 = new GenericFrontEndAsync("__test2__", request => requested2 = request.Method === "__test2__");
        FrontEndAsyncInterface.register(requestHandler2, "__test2__");
        expect(requested2).toBe(false);
        window.InvokeFrontEndAsync({ Method: "__test2__" });
        expect(requested2).toBe(true);
    });

    test("Testing with fallback to Transcendence", () => {
        const window1 = { InvokeFrontEndAsync: (_: any) => { } };
        FrontEndAsyncInterface.initialize(window1, null);

        expect(() => window1.InvokeFrontEndAsync({ Method: "__test3__" })).toThrow();

        let fellBack = false;
        const window2 = { InvokeFrontEndAsync: (_: any) => { } };
        const transcendence = { invokeFrontEndAsync: (request: IFrontEndAsyncRequest) => fellBack = request.Method === "__test3__" } as ITranscendence;
        FrontEndAsyncInterface.initialize(window2, transcendence);

        expect(fellBack).toBe(false);
        window2.InvokeFrontEndAsync({ Method: "__test3__" });
        expect(fellBack).toBe(true);

        expect(() => window2.InvokeFrontEndAsync({ Method: "__test_unknown__" })).toThrowError(InvalidRequestError);
    });

    test("Testing with explicit fallback to Transcendence", () => {
        const window1 = { InvokeFrontEndAsync: (_: any) => { } };
        FrontEndAsyncInterface.initialize(window1, null);

        const requestHandler1 = new GenericFrontEndAsync("__test4__", request => FALLBACK_TO_TRANSCENDENCE);
        FrontEndAsyncInterface.register(requestHandler1, "__test4__");

        let fellBack = false;
        const window2 = { InvokeFrontEndAsync: (_: any) => { } };
        const transcendence = { invokeFrontEndAsync: (request: IFrontEndAsyncRequest) => fellBack = request.Method === "__test4__" } as ITranscendence;
        FrontEndAsyncInterface.initialize(window2, transcendence);

        expect(fellBack).toBe(false);
        window2.InvokeFrontEndAsync({ Method: "__test4__" });
        expect(fellBack).toBe(true);
    });

    test("Testing with actual Transcendence", async () => {
        const transcendence = await getTranscendenceInstance(null, null);
        const window = { InvokeFrontEndAsync: (_: any) => { } };
        FrontEndAsyncInterface.initialize(window, transcendence);

        window.InvokeFrontEndAsync({ Method: "ConfigureSecureMethods", notrace: true });
    });

    test("Testing with implicitly named request handler", () => {
        class ImplicitlyNamedTestHandler extends FrontEndAsyncRequestHandler {
            handle(request: IFrontEndAsyncRequest) {
                return false;
            }

            get name(): string {
                return this.constructor.name;
            }
        }

        FrontEndAsyncInterface.register(new ImplicitlyNamedTestHandler());

    });

    test("Testing initialization without target or with clean target", () => {
        FrontEndAsyncInterface.initialize(null);

        const window: any = {};
        FrontEndAsyncInterface.initialize(window);
        expect(typeof window["InvokeFrontEndAsync"]).toBe("function");
    });

});
