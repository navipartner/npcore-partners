import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import {
    DRAGONGLASS_THEME_DEFINE
} from "../actions/themeActionTypes.js";

const defineStateArrayFromPayload = (newState, payload, prop) => {
    if (payload[prop]) {
        newState[prop] = [...newState[prop], ...payload[prop]];
        return true;
    }
    return false;
};

const themes = createReducer(initialState.themes, {
    [DRAGONGLASS_THEME_DEFINE]: (state, payload) => {
        const newState = { ...state };
        let changed = false;

        changed |= defineStateArrayFromPayload(newState, payload, "styles")
        changed |= defineStateArrayFromPayload(newState, payload, "scripts");

        if (payload.background) {
            if (payload.background.view)
                newState.background.view = { ...newState.background.view, ...payload.background.view };
            if (payload.background.viewType)
                newState.background.viewType = { ...newState.background.viewType, ...payload.background.viewType };
            changed = true;
        }

        if (payload.logo) {
            newState.logo = payload.logo;
            changed = true;
        }

        return changed ? newState : state;
    }
});

export default themes;

const themeStylesMap = {
    state: state => {
        const { styles } = state.themes;
        return (styles.length)
            ? { styleInnerHtml: styles.join("\n") }
            : {};
    },
    enhancer: (next, prev) => next.themes === prev.themes && next.themes.styles === prev.themes.styles
};

const themeMap = {
    state: (_, ownProps) =>
        state => {
            const { themes } = state, { imageId } = ownProps;
            return { src: themes.hasOwnProperty(imageId) ? themes[imageId] : "" };
        },
    enhancer: {
        areStatesEqual: (next, prev) => next.themes === prev.themes
    }
};

export const bindComponentToThemeStylesState = component => bindToMap(component, themeStylesMap);
export const bindComponentToThemesState = component => bindToMap(component, themeMap);
