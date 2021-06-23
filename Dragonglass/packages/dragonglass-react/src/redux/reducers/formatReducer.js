import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import { DRAGONGLASS_FORMAT_SET } from "../actions/formatActionTypes.js";

const format = createReducer(initialState.format, {
    [DRAGONGLASS_FORMAT_SET]: (state, payload) => {
        const { number, date } = payload;
        if (!number && !date)
            return state;

        const result = Object.assign({}, state);
        number && (result.number = number);
        date && (result.date = date);
        result.generation = (result.generation || 0) + 1;
        return result;
    }
});

export default format;

const formatMap = {
    state: state => {
        const { format } = state;
        return { format: format };
    },
    enhancer: {
        areStatesEqual: (next, prev) => next.format === prev.format && next.format.generation === prev.format.generation
    }
};

export const bindComponentToFormatState = component => bindToMap(component, formatMap);
