export interface StateSubscriber<T> {
    (state: T): void;
}