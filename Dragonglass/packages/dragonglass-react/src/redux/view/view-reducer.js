import { combineReducers } from "redux";
import { createReducer } from "dragonglass-redux";
import initialState from "./view-initial";
import {
  DRAGONGLASS_VIEW_DEFINE,
  DRAGONGLASS_VIEW_RESET,
  DRAGONGLASS_VIEW_SET_ACTIVE,
} from "./view-actions";

const active = createReducer("", {
  [DRAGONGLASS_VIEW_SET_ACTIVE]: (state, payload) =>
    state === payload ? state : payload,
});

const views = createReducer(initialState.views, {
  [DRAGONGLASS_VIEW_DEFINE]: (state, payload) => {
    const { tag } = payload;
    if (state.layouts[tag] && state.layouts[tag] === payload) return state;

    const views = [...new Set([...state.tags, tag])];
    return Object.assign({}, state, {
      layouts: { ...state.layouts, [tag]: { ...payload } },
      tags: views,
    });
  },
  [DRAGONGLASS_VIEW_RESET]: () => initialState,
});

export default combineReducers({
  active,
  views,
});
