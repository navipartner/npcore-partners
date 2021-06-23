export interface NAVInvoker<T> {
    raise(payload?: T): Promise<string>;
}
