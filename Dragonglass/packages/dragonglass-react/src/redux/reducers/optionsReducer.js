import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import {
    DRAGONGLASS_OPTIONS_SET
} from "../actions/optionsActionTypes.js";

const options = createReducer(initialState.options, {
    [DRAGONGLASS_OPTIONS_SET]: (state, payload) => {
        const result = { ...state, ...payload };
        return result;
    }
});

export default options;

const optionsMap = {
    state: state => {
        const { options } = state;
        return options;
    }
};

const singleOptionMap = {
    state: (state, ownProps) => {
        const { options } = state;
        const optionValue = options[ownProps.option];
        return { optionValue };
    },
    enhancer: {
        areStatesEqual: (next, prev) => {
            return next.options === prev.options;
        }
    }
};

export const bindComponentToOptionsState = component => bindToMap(component, optionsMap);
export const bindComponentToSingleOptionState = component => bindToMap(component, singleOptionMap);
