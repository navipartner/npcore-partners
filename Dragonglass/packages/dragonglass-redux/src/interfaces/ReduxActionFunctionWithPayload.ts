import { ReduxActionWithPayload } from "./ReduxActionWithPayload";

export interface ReduxActionFunctionWithPayload<T> {
    (payload: T): ReduxActionWithPayload<T>;
};
