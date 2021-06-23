import { Singleton } from "../../src/classes/Singleton";
import { SingletonViolationError } from "../../src/errors/SingletonViolationError";

describe("Singleton class", () => {

    afterEach(() => jest.resetModules());

    test("Attempting to instantiate from the base Singleton class", () => {
        expect(() => {
            const first = new Singleton();
        }).toThrowError(SingletonViolationError);

        try {
            const first = new Singleton();
            throw new Error("Failure was expected, but didn't occur.");
        } catch(error) {
            expect(error.constructor).toBe(SingletonViolationError);
            expect(error.base).toBe(true);
        }
    });

    test("Extending Singleton", () => {
        class TestSingleton1 extends Singleton { }

        const first = new TestSingleton1();
    });

    test("Attempting to instantiate multiple instancess from extended Singleton", () => {
        expect(() => {
            class TestSingleton2 extends Singleton { }

            const first = new TestSingleton2();
            const second = new TestSingleton2();
        }).toThrowError(SingletonViolationError);
    });

    test("Accessing Singleton through 'instance' property", () => {
        class TestSingleton3 extends Singleton { }
        class TestSingleton4 extends Singleton {}

        const first = new TestSingleton3();
        expect(first).toBeDefined();
        expect(TestSingleton3.instance).toBeDefined();
        expect(TestSingleton3.instance).toBe(first);

        const second = new TestSingleton4();
        expect(second).toBeDefined();
        expect(TestSingleton4.instance).toBeDefined();
        expect(TestSingleton4.instance).toBe(second);
    });

});