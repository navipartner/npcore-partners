import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import { DRAGONGLASS_TRANSACTIONSTATE_UPDATE } from "../actions/transactionStateActions.js";

const transactionState = createReducer(initialState.transactionState, {
    [DRAGONGLASS_TRANSACTIONSTATE_UPDATE]: (state, payload) => ({ ...state, ...payload })
});

export default transactionState;

const transactionStateMap = {
    state: state => ({ transactionState: state.transactionState }),
    enhancer: {
        areStatesEqual: (next, prev) =>
            next.transactionState.no === prev.transactionState.no &&
            next.transactionState.register === prev.transactionState.register &&
            next.transactionState.salesPerson === prev.transactionState.salesPerson
    }
};

export const bindComponentToTransactionState = component => bindToMap(component, transactionStateMap);
