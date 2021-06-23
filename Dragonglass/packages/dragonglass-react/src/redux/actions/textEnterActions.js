import {
    DRAGONGLASS_TEXTENTER_OPEN,
    DRAGONGLASS_TEXTENTER_CLOSE,
    DRAGONGLASS_TEXTENTER_REMOVE
} from "./textEnterActionTypes";

export const openTextEnter = (textEntry, id) => ({
    type: DRAGONGLASS_TEXTENTER_OPEN,
    payload: { textEntry, id }
});

export const closeTextEnter = (textEntry, id) => dispatch => {
    // Dispatch the close action to indicate the closing state
    dispatch({
        type: DRAGONGLASS_TEXTENTER_CLOSE,
        payload: { textEntry, id }
    });

    // Dispatch the remove action to remove from state
    setTimeout(() => dispatch({
        type: DRAGONGLASS_TEXTENTER_REMOVE,
        payload: { textEntry, id }
    }), 1000);
};