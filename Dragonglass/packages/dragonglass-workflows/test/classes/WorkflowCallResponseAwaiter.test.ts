import { WorkflowCallResponseAwaiter } from "../../src/classes/WorkflowCallResponseAwaiter";

describe("WorkflowCallResponseAwaiter class", () => {
    
    test("Test case #1: completeCall then respond", () => {
        const callback = jest.fn();
        const awaiter = new WorkflowCallResponseAwaiter(callback);
        expect(callback).not.toBeCalled();

        awaiter.completeCall();
        expect(callback).not.toBeCalled();

        awaiter.respond("__test__");
        expect(callback).toBeCalledWith("__test__");
    });
    
    test("Test case #2: respond then completeCall", () => {
        const callback = jest.fn();
        const awaiter = new WorkflowCallResponseAwaiter(callback);
        expect(callback).not.toBeCalled();

        awaiter.respond("__test__");
        expect(callback).not.toBeCalled();

        awaiter.completeCall();
        expect(callback).toBeCalledWith("__test__");
    });
});