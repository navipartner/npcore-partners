import { ReduxHandler } from "./interfaces/ReduxHandler";
import { ReduxReducer } from "./interfaces/ReduxReducer";

/**
 * Creates a reducer function from the handlers object by testing if the passed object contains the function matching
 * the name mapped to the action type. If so, invokes that function as a reducer function, otherwise returns state.
 * This gets rid of switch boilerplate in reducer functions.
 *
 * @export
 * @param {*} initialState Indicates the initial state for the reducer function
 * @param {*} handlers Object containing methods, each representing a reducer with a name matching an action type
 * @returns A high-level reducer function that maps actions to individual reducer functions.
 */
export function createReducer<T>(initialState: T, handlers: { [key: string]: ReduxHandler<T> }): ReduxReducer<T> {
    return (state = initialState, action: any) => {
        const { type, payload, ...middleware } = action;
        return typeof handlers[type] === "function"
            ? handlers[type](state, payload, middleware)
            : state;
    }
};
