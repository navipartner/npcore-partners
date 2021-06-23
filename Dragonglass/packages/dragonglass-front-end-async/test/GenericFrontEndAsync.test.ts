import { GenericFrontEndAsync } from "../src/GenericFrontEndAsync";
import { IFrontEndAsyncRequest } from "../src/interfaces/IFrontEndAsyncRequest";

describe("GenericFrontEndAsync class", () => {

    test("Instanting with correct parameter types", () => {
        const result = Symbol();

        const handler = new GenericFrontEndAsync("__test__", () => result);
        expect(handler.name).toBe("__test__");
        expect(handler.handle({ Method: "__none__" } as IFrontEndAsyncRequest)).toBe(result);
    });

});
