import {
    DRAGONGLASS_OPTIONS_SET
} from "./optionsActionTypes";

export const setOptions = options =>
    ({
        type: DRAGONGLASS_OPTIONS_SET,
        payload: options
    });
