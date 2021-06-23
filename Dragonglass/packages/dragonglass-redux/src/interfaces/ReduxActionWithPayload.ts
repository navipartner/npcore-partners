import { ReduxAction } from "./ReduxAction";

export interface ReduxActionWithPayload<T> extends ReduxAction {
    payload: T;
};
