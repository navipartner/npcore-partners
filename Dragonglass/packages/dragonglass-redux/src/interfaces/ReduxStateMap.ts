export interface ReduxStateMap<T, U> {
    state: (state: T) => U;
};
