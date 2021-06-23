import { DRAGONGLASS_FORMAT_SET } from "./formatActionTypes";

export const setFormatAction = format => ({
    type: DRAGONGLASS_FORMAT_SET,
    payload: format
});