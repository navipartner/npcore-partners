import { ReduxAction } from "./ReduxAction";

export interface ReduxActionFunction {
    (): ReduxAction;
};
