import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import {
    DRAGONGLASS_ERROR_RAISE,
    DRAGONGLASS_ERROR_DISMISS,
    DRAGONGLASS_ERROR_DISMISS_ALL
} from "../actions/errorActionTypes";
import { raiseError, dismissError, dismissAll } from "../actions/errorActions";

let nextErrorId = 0;

const errors = createReducer(initialState.errors, {
    [DRAGONGLASS_ERROR_RAISE]: (state, payload) => {
        const error = { ...payload };
        if (!error.id)
            error.id = ++nextErrorId;
        const newState = [...state, error];
        return newState;
    },

    [DRAGONGLASS_ERROR_DISMISS]: (state, payload) => [...state.filter(error => error.id !== payload)],

    [DRAGONGLASS_ERROR_DISMISS_ALL]: () => []
});

export default errors;

const errorsMap = {
    state: state => ({ errors: state.errors }),
    dispatch: dispatch => ({
        raise: error => dispatch(raiseError(error)),
        dismiss: id => dispatch(dismissError(id)),
        dismissAll: () => dispatch(dismissAll())
    })
};

export const bindComponentToErrorsState = component => bindToMap(component, errorsMap);
