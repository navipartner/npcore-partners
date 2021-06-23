import { ALRuntimeError } from "../../src/errors/ALRuntimeError";

describe("ALRuntimeError class", () => {

    const noPopup = {
        error: async (_: any) => {}
    };

    test("Instantiation and content", async () => {

        const error1 = new ALRuntimeError("__test__", false, noPopup);
        const error2 = new ALRuntimeError("__test__", true, noPopup);

        expect(error1.message).toMatch("__test__");
        expect(error1.ALError.originalMessage).toBe("__test__");
        expect(error1.ALError.silent).toBe(false);
        expect(error2.ALError.silent).toBe(true);
    });

    test("toString() method", () => {
        const error1 = new ALRuntimeError("__test__", false, noPopup);
        const toString1 = error1.toString();
        const template1 = `${error1}`;
        expect(toString1).toBe(template1);

        const error2 = new ALRuntimeError("", false, noPopup);
        const toString2 = error2.toString();
        expect(toString2).toMatch("rollback");
    });

    test("Showing popup when original error is present", async () => {
        const popup = {
            error: jest.fn()
        };

        const error = new ALRuntimeError("__test__", false, popup);

        expect(error.message).toMatch("__test__");
        expect(error.ALError.originalMessage).toBe("__test__");
        expect(error.ALError.popupShown).toBe(false);

        await error.showALError();
        expect(popup.error).toBeCalled();
        expect(error.ALError.popupShown).toBe(true);

        await error.showALError();
        expect(popup.error).toBeCalledTimes(1);
    });

    test("Showing popup when original error is absent", async () => {
        const popup = {
            error: jest.fn()
        };

        const error = new ALRuntimeError("", false, popup); // when AL does Error('');
        await error.showALError();
        expect(popup.error).not.toBeCalled();
        expect(error.ALError.popupShown).toBe(true);
    });

});