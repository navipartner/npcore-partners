import { compose, createStore, applyMiddleware, combineReducers, Store, Action, Unsubscribe, Reducer, CombinedState } from "redux";
import thunk from "redux-thunk";
import { ReduxAction } from "./interfaces/ReduxAction";
import { ReduxReducer } from "./interfaces/ReduxReducer";
import { ReduxState } from "./interfaces/ReduxState";
import { IDataStatesForAL } from "./state/IDataStatesForAL";
import { StateSelector } from "./StateSelector";
import { StateSubscriber } from "./StateSubscriber";

export class StateStore {
    private static _instance: StateStore;

    private _store: Store<any>; // Typing to any because store will be extended with unknown substate types at runtime and typing will be achieved at getStatea level
    private _initialReducerMap: { [key: string]: Reducer<any> };
    private _composer: <T>(target: T) => T;
    private _injectedReducers: { [key: string]: Reducer<any> } = {};
    private _selectors: Array<{ selector: Function, subscriber: Function }> = [];
    private _currentState: Object = {};

    constructor(initialReducerMap: { [key: string]: Reducer<any> }, composeEnhancers: <T>(target: T) => T = compose) {
        if (StateStore._instance)
            console.warn("Only one instance of StateStore is needed. Your attempt to instantiate another one may lead to problems.");

        StateStore._instance = this;

        this._initialReducerMap = initialReducerMap;
        this._composer = composeEnhancers;

        this._store = createStore(
            combineReducers(this._initialReducerMap),
            this._composer<any>(applyMiddleware(thunk))
        );

        this._wireUpSelectorSubscriptions();
    }

    private _wireUpSelectorSubscriptions() {
        this._store.subscribe(() => {
            const state = this._store.getState();
            if (this._currentState === state)
                return;

            for (let selector of this._selectors) {
                let selectedState = selector.selector(state, this._currentState);
                if (selectedState)
                    selector.subscriber(selectedState);
            }

            this._currentState = state;
        });
    }


    //#region Redux wrapper

    public getState<T extends ReduxState>(): T {
        return this._store.getState() as T;
    }

    public dispatch<T extends ReduxAction>(action: T): T {
        return this._store.dispatch(action);
    }

    public subscribe(listener: any): Unsubscribe {
        return this._store.subscribe(listener);
    }

    public replaceReducer(next: Reducer): void {
        this._store.replaceReducer(next);
    }

    //#endregion

    //#region Dragonglass sugar

    public injectReducer<T>(root: string, reducer: ReduxReducer<T>): void {
        this._injectedReducers[root] = reducer;
        this._store.replaceReducer(combineReducers({
            ...this._initialReducerMap,
            ...this._injectedReducers
        }));
    }

    public subscribeSelector<T, U>(selector: StateSelector<T, U>, subscriber: StateSubscriber<U>): void {
        this._selectors.push({ selector, subscriber });
    };

    public getDataStates(): IDataStatesForAL | {} {
        const { data } = this._store.getState();
        if (!data)
            return {};

        const result: IDataStatesForAL = { data: { positions: {} } };

        Object.keys(data.sets).forEach(key => {
            const position = data.sets[key].currentPosition;
            if (position && !position.startsWith("fake"))
                result.data.positions[key] = position;
        });
        return result;
    }

    public appendDataStatesToTarget(target: any) {
        const newContext = target && typeof target === "object"
            ? target
            : {};

        return {
            ...newContext,
            ...this.getDataStates()
        };
    }

    public get internalReduxStore() {
        return this._store;
    }

    //#endregion

    public static get instance() {
        return this._instance;
    }
}
