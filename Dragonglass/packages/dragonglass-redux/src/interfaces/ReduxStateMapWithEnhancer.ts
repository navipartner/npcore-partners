import { ReduxStateMap } from "./ReduxStateMap";

export interface ReduxStateMapWithEnhancer<T, U> extends ReduxStateMap<T, U> {
    enhancer: {
        areStatesEqual: (next: T, prev: T) => boolean;
    }
};
