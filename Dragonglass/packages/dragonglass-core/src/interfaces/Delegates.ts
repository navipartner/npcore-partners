export interface Delegate {
    (): void;
}

export interface Delegate_T<T> {
    (arg0: T): void;
}

export interface Delegate_T_U<T, U> {
    (arg0: T, arg1: U): void;
}

export interface Delegate_T_U<T, U> {
    (arg0: T, arg1: U): void;
}

export interface Delegate_T_U_V<T, U, V> {
    (arg0: T, arg1: U, arg2: V): void;
}

export interface Func<R> {
    (): R;
}

export interface Func_T<T, R> {
    (arg0: T): R;
}

export interface Func_T_U<T, U, R> {
    (arg0: T, arg1: U): R;
}

export interface Func_T_U_V<T, U, V, R> {
    (arg0: T, arg1: U, arg2: V): R;
}

export interface Predicate {
    (): boolean;
}

export interface Predicate_T<T> {
    (arg0: T): boolean;
}
