import { rootReducer } from "./rootReducer.js";
import { StateStore as DragonglassStateStore } from "dragonglass-redux";

export const StateStore = new DragonglassStateStore(
  rootReducer,
  window.top.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__
);
