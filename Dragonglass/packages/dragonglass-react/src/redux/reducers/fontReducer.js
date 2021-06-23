import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import {
    DRAGONGLASS_FONT_DEFINE
} from "../actions/fontActionTypes";

const fonts = createReducer(initialState.fonts, {
    [DRAGONGLASS_FONT_DEFINE]: (state, payload) => {
        const newState = state.filter(font => font.prefix !== payload.prefix);
        newState.push(payload);
        return newState;
    }
});

export default fonts;

const fontMap = {
    state: state => ({ fonts: state.fonts })
};

export const bindComponentToFontsState = component => bindToMap(component, fontMap);
