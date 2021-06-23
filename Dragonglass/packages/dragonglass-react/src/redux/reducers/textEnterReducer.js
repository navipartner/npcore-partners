import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import {
    DRAGONGLASS_TEXTENTER_OPEN,
    DRAGONGLASS_TEXTENTER_CLOSE,
    DRAGONGLASS_TEXTENTER_REMOVE
} from "../actions/textEnterActionTypes";

const EMPTY_TEXTENTER_ARRAY = [];

const textEnter = createReducer(initialState.textEnter, {
    [DRAGONGLASS_TEXTENTER_OPEN]: (state, payload) => {
        const { textEntry, id } = payload;
        const newState = { ...state };
        newState[id] = [...(newState[id] || EMPTY_TEXTENTER_ARRAY)];
        newState[id].push(textEntry);
        newState[id] = newState[id].sort((left, right) => right.id - left.id);
        return newState;
    },

    [DRAGONGLASS_TEXTENTER_CLOSE]: (state, payload) => {
        const { textEntry, id } = payload;
        const newState = { ...state };
        newState[id] = [...(newState[id] || EMPTY_TEXTENTER_ARRAY)];
        let found = false;
        for (var i = 0; i < newState[id].length; i++) {
            const entry = newState[id][i];
            if (entry === textEntry) {
                newState[id][i] = { ...entry, closing: true };
                found = true;
            }
        }
        return found ? newState : state;
    },

    [DRAGONGLASS_TEXTENTER_REMOVE]: (state, payload) => {
        const { textEntry, id } = payload;
        const newState = { ...state };
        newState[id] = newState[id].filter(entry => entry.id !== textEntry.id);
        return state[id].length === newState[id].length
            ? state
            : newState;
    }
});

export default textEnter;

const textEnterMap = {
    state: (state, ownProps) => ({ textEnter: state.textEnter[ownProps.id] || EMPTY_TEXTENTER_ARRAY }),
    enhancer: {
        areStatesEqual: (next, prev) => next.textEnter === prev.textEnter
    }
};

const textEnterEntryMap = {
    state: (state, ownProps) => ({ entry: state.textEnter[ownProps.hostId].find(entry => entry.id === ownProps.id) }),
    enhancer: {
        areStatesEqual: (next, prev) => next.textEnter === prev.textEnter
    }
};

export const bindComponentToTextEnterState = component => bindToMap(component, textEnterMap);
export const bindComponentToTextEnterEntryState = component => bindToMap(component, textEnterEntryMap);