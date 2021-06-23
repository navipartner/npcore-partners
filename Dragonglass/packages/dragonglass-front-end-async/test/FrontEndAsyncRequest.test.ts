import { FrontEndAsyncRequestHandler } from "../src/FrontEndAsyncRequestHandler";
import { IFrontEndAsyncRequest } from "../src/interfaces/IFrontEndAsyncRequest";

describe("FrontEndAsync class inheritance", () => {

    class Test1 extends FrontEndAsyncRequestHandler {
        handle(request: IFrontEndAsyncRequest) {
            throw new Error("Method not implemented.");
        }
    }

    class Test2 extends FrontEndAsyncRequestHandler {
        handle(request: IFrontEndAsyncRequest) {
            throw new Error("Method not implemented.");
        }
    }

    class Test3 extends FrontEndAsyncRequestHandler {
        handle(request: IFrontEndAsyncRequest) {
            throw new Error("Method not implemented.");
        }

        public get name() {
            return "__test_3__";
        }
    }

    test("Testing default name", () => {
        const test1 = new Test1();
        const test2 = new Test2();
        const test3 = new Test3();

        expect(test1.name).toBe("Test1");
        expect(test2.name).toBe("Test2");
        expect(test3.name).toBe("__test_3__");
    });
});
