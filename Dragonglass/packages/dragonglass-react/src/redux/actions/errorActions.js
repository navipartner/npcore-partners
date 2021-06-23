import {
    DRAGONGLASS_ERROR_RAISE,
    DRAGONGLASS_ERROR_DISMISS,
    DRAGONGLASS_ERROR_DISMISS_ALL
} from "./errorActionTypes";

export const raiseError = error => ({
    type: DRAGONGLASS_ERROR_RAISE,
    payload: error
});

export const dismissError = error => ({
    type: DRAGONGLASS_ERROR_DISMISS,
    payload: error
});

export const dismissAll = () => ({ type: DRAGONGLASS_ERROR_DISMISS_ALL });
