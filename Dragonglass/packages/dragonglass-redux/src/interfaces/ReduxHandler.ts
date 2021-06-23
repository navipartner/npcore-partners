export interface ReduxHandler<T> {
    (
        state: T,
        payload?: any,
        middleware?: any
    ): T;
};
