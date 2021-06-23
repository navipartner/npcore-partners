import {
  DRAGONGLASS_POPUP_SHOW,
  DRAGONGLASS_POPUP_REMOVE,
  DRAGONGLASS_POPUP_CLEAR,
} from "./popupActionTypes";

export const showPopupAction = (dialog) => {
  return {
    type: DRAGONGLASS_POPUP_SHOW,
    payload: dialog,
  };
};

/**
 * Removes the dialog from the state store.
 * @param {Number} id ID of the dialog to be removed.
 */
export const removePopupAction = (id) => ({
  type: DRAGONGLASS_POPUP_REMOVE,
  payload: id,
});

/**
 * Removes all dialogs from the state store. This action should be invoked only when dialog state absolutely has to be reset
 * (e.g. changing views, timing out, etc...)
 */
export const clearPopupsAction = () => ({
  type: DRAGONGLASS_POPUP_CLEAR,
});
