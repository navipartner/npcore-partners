import { createReducer } from "dragonglass-redux";
import {
  DRAGONGLASS_MENU_DEFINE,
  DRAGONGLASS_MENU_RESET,
} from "../actions/menuActionTypes";
import menuInitial from "./menu-initial";

const menu = createReducer(menuInitial, {
  [DRAGONGLASS_MENU_DEFINE]: (state, payload) => {
    const newState = { ...state, ...payload };
    newState._generation++;
    for (var key in payload)
      newState[key].generation =
        ((state[key] && state[key].generation) || 0) + 1;
    return newState;
  },

  [DRAGONGLASS_MENU_RESET]: (state) => {
    const newState = { ...state };
    newState._generation++;

    for (let key in state) {
      if (
        typeof newState[key] === "object" &&
        typeof newState[key].generation === "number"
      )
        newState[key].generation++;
    }

    return newState;
  },
});

export default menu;
