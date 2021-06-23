import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import {
  DRAGONGLASS_POPUP_SHOW,
  DRAGONGLASS_POPUP_REMOVE,
  DRAGONGLASS_POPUP_CLEAR,
} from "../actions/popupActionTypes.js";
import {
  showPopupAction,
  closePopupAction,
  removePopupAction,
} from "../actions/popupActions.js";

const popups = createReducer(initialState.popups, {
  [DRAGONGLASS_POPUP_SHOW]: (state, payload) => {
    const newState = [...state, payload];
    return newState;
  },

  [DRAGONGLASS_POPUP_REMOVE]: (state, payload) => [
    ...state.filter((popup) => popup.id !== payload),
  ],

  [DRAGONGLASS_POPUP_CLEAR]: () => [],
});

export default popups;

const popupsMap = {
  state: (state) => ({ popups: state.popups }),
  dispatch: (dispatch) => ({
    show: (dialog) => dispatch(showPopupAction(dialog)),
    remove: (id) => dispatch(removePopupAction(id)),
  }),
  enhancer: {
    areStatesEqual: (next, prev) => next.popups === prev.popups,
  },
};

export const bindComponentToPopupsState = (component) =>
  bindToMap(component, popupsMap);
