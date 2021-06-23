import { ReduxActionFunction } from "./interfaces/ReduxActionFunction";
import { ReduxActionFunctionWithPayload } from "./interfaces/ReduxActionFunctionWithPayload";

export function createAction(type: string): ReduxActionFunction {
    return () => ({
        type
    });
};

export function createActionWithPayload<T>(type: string): ReduxActionFunctionWithPayload<T> {
    return (payload: T) => ({
        type,
        payload
    });
};
