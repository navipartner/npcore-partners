export interface StateSelector<T, U> {
    (next: T, prev: T): U | false;
}
