import { IResolver } from "../../src/interfaces/IResolver";
import { CounterAwaiter } from "../../src/classes/CounterAwaiter";

describe("CounterAwaiter class", () => {
    async function runSafe() {
        const awaiter = new CounterAwaiter();
        const resolvers: IResolver[] = [];
        const number = 1 + Math.round(Math.random() * 10);

        expect(awaiter.awaitable).toBe(false);
        expect(awaiter.resolved).toBe(false);
        for (let i = 0; i < number; i++) {
            resolvers.push(awaiter.start());
            expect(awaiter.awaitable).toBe(true);
            expect(awaiter.resolved).toBe(false);
        }

        const resolve = (i: number) => setTimeout(() => resolvers[i].resolve(), Math.random() * 200);
        for (let i = 0; i < number; i++) {
            resolve(i);
        }

        await awaiter.await();

        expect(awaiter.awaitable).toBe(false);
        expect(awaiter.resolved).toBe(true);
    }

    async function runUnsafe() {
        const awaiter = new CounterAwaiter();
        const wrapper = { start: awaiter.start, await: awaiter.await };
        const resolvers: IResolver[] = [];
        const number = 1 + Math.round(Math.random() * 10);

        expect(awaiter.awaitable).toBe(false);
        expect(awaiter.resolved).toBe(false);
        for (let i = 0; i < number; i++) {
            let resolver = wrapper.start();
            let resolve = resolver.resolve;
            resolvers.push({ resolve });
            expect(awaiter.awaitable).toBe(true);
            expect(awaiter.resolved).toBe(false);
        }

        const resolveFunc = (i: number) => setTimeout(() => resolvers[i].resolve(), Math.random() * 200);
        for (let i = 0; i < number; i++) {
            resolveFunc(i);
        }

        await wrapper.await();

        expect(awaiter.awaitable).toBe(false);
        expect(awaiter.resolved).toBe(true);
    }

    test("Awaiting on zero instances", async () => {
        const awaiter = new CounterAwaiter();

        expect(awaiter.awaitable).toBe(false);
        expect(awaiter.resolved).toBe(false);
        await awaiter.await();
        expect(awaiter.awaitable).toBe(false);
        expect(awaiter.resolved).toBe(true);
    });

    test("Awaiting on a random number of instances", async () => await runSafe());

    test("Awaiting on a random number of instances (closure safety test)", async () => await runUnsafe());

    test("Awaiting on a random number of instances - parallel", async () => {
        for (let i = 0; i < 10; i++)
            await runSafe();
    });

    test("Awaiting on a random number of instances (closure safety test) - parallel", async () => {
        for (let i = 0; i < 10; i++)
            await runUnsafe();
    });
});