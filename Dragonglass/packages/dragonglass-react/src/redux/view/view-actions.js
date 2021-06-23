/** Updates a view JSON definition */
export const DRAGONGLASS_VIEW_DEFINE = "DRAGONGLASS_VIEW_DEFINE";

/** Resets the entire view state. All existing cached views are cleared */
export const DRAGONGLASS_VIEW_RESET = "DRAGONGLASS_VIEW_RESET";

/** Sets active view */
export const DRAGONGLASS_VIEW_SET_ACTIVE = "DRAGONGLASS_VIEW_SET_ACTIVE";

export const setActiveViewAction = (tag) => {
  return {
    type: DRAGONGLASS_VIEW_SET_ACTIVE,
    payload: tag,
  };
};

export const defineViewAction = (view) => {
  return {
    type: DRAGONGLASS_VIEW_DEFINE,
    payload: view,
  };
};
