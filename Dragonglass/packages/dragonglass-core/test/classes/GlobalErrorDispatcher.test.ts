import GlobalErrorDispatcher, { GLOBAL_ERRORS } from "./../../src/classes/GlobalErrorDispatcher";

describe("GlobalErrorDispatcher class", () => {
    test("General functionality", () => {
        const subscriber = jest.fn();
        GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.CRITICAL_ERROR, subscriber);
        expect(() => GlobalErrorDispatcher.addEventListener("__error__", subscriber)).toThrow();

        GlobalErrorDispatcher.raise(GLOBAL_ERRORS.CRITICAL_ERROR);
        GlobalErrorDispatcher.raiseCriticalError(null);
        GlobalErrorDispatcher.removeEventListener(GLOBAL_ERRORS.CRITICAL_ERROR, subscriber);
        GlobalErrorDispatcher.raise(GLOBAL_ERRORS.SILENT_AL_ERROR);
        expect(() => GlobalErrorDispatcher.raise("__error__")).toThrow();
        GlobalErrorDispatcher.raise(GLOBAL_ERRORS.CRITICAL_ERROR);
        GlobalErrorDispatcher.raiseCriticalError(null);
        expect(subscriber).toBeCalledTimes(2);
    });

    test("Critical error serializable content", () => {
        const subscriber = jest.fn((error, serialized) => {
            expect(error).toBeDefined();
            expect(serialized.message).toBe("__test__");
            expect(`${error}`).toMatch("__test__");
            expect(serialized.date).toBeDefined();
        });

        GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.CRITICAL_ERROR, subscriber);
        GlobalErrorDispatcher.raiseCriticalError("__test__");
        GlobalErrorDispatcher.raiseCriticalError(new Error("__test__"));
        expect(subscriber).toBeCalledTimes(2);
    });

    test("Silent AL error", () => {
        const subscriber = jest.fn(error => expect(error).toBe("__test__"));
        GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.SILENT_AL_ERROR, subscriber);
        GlobalErrorDispatcher.raise(GLOBAL_ERRORS.SILENT_AL_ERROR, "__test__");
        GlobalErrorDispatcher.raiseSilentALError("__test__");
        expect(subscriber).toBeCalledTimes(2);
    });

    test("Unhandled AL error", () => {
        const subscriber = jest.fn(error => expect(error).toBe("__test__"));
        GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.UNHANDLED_AL_ERROR, subscriber);
        GlobalErrorDispatcher.raise(GLOBAL_ERRORS.UNHANDLED_AL_ERROR, "__test__");
        GlobalErrorDispatcher.raiseUnhandledALError("__test__");
        expect(subscriber).toBeCalledTimes(2);
    });
});
