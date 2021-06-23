import { DRAGONGLASS_THEME_DEFINE } from "./themeActionTypes";

export const defineThemeAction = theme => ({
    type: DRAGONGLASS_THEME_DEFINE,
    payload: theme
});