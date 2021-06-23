import GlobalEventDispatcher, { GLOBAL_EVENTS } from "./../../src/classes/GlobalEventDispatcher";

describe("GlobalEventDispatcher class", () => {
    test("General functionality", () => {
        const subscriber = jest.fn();
        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.FRAMEWORK_READY, subscriber);
        expect(() => GlobalEventDispatcher.addEventListener("__error__", subscriber)).toThrow();

        GlobalEventDispatcher.raise(GLOBAL_EVENTS.FRAMEWORK_READY);
        GlobalEventDispatcher.frameworkReady();
        GlobalEventDispatcher.removeEventListener(GLOBAL_EVENTS.FRAMEWORK_READY, subscriber);
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.TRANSACTION_START);
        expect(() => GlobalEventDispatcher.raise("__error__")).toThrow();
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.FRAMEWORK_READY);
        GlobalEventDispatcher.frameworkReady();
        expect(subscriber).toBeCalledTimes(2);
    });

    test("Start transaction - multiple arguments", () => {
        const startTransaction1 = jest.fn((e1: any, e2: any, e3: any) => {
            expect(e1).toBeUndefined();
            expect(e2).toBeUndefined();
            expect(e3).toBeUndefined();
        });

        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.TRANSACTION_START, startTransaction1);
        GlobalEventDispatcher.startTransaction();
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.TRANSACTION_START);
        GlobalEventDispatcher.removeEventListener(GLOBAL_EVENTS.TRANSACTION_START, startTransaction1);

        const startTransaction2 = jest.fn((e1: any, e2: any, e3: any) => {
            expect(e1).toBe(1);
            expect(e2).toBe(2);
            expect(e3).toBe(3);
        });
        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.TRANSACTION_START, startTransaction2);
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.TRANSACTION_START, 1, 2, 3);
        GlobalEventDispatcher.removeEventListener(GLOBAL_EVENTS.TRANSACTION_START, startTransaction2);
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.TRANSACTION_START, 1, 2, 3);

        expect(startTransaction1).toBeCalledTimes(2);
        expect(startTransaction2).toBeCalledTimes(1);
    });

    test("Button Click", () => {
        const buttonClick = jest.fn();
        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.BUTTON_CLICK, buttonClick);
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.BUTTON_CLICK);
        GlobalEventDispatcher.buttonClick({});

        expect(buttonClick).toBeCalledTimes(2);
    });

    test("Refresh Data", () => {
        const refreshData = jest.fn();
        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.REFRESH_DATA, refreshData);
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.REFRESH_DATA);
        GlobalEventDispatcher.refreshData({});

        expect(refreshData).toBeCalledTimes(2);
    });
});
