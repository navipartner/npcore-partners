import { DRAGONGLASS_FONT_DEFINE } from "./fontActionTypes";

export const defineFontAction = font => ({
    type: DRAGONGLASS_FONT_DEFINE,
    payload: font
});
