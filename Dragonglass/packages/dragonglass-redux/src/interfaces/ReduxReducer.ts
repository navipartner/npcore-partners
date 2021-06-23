import { ReduxAction } from "./ReduxAction";

export interface ReduxReducer<T> {
    (
        state: T,
        action: ReduxAction
    ): T;
};
