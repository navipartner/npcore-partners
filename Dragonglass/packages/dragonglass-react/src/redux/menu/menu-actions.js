/** Updates menu definitions */
export const DRAGONGLASS_MENU_DEFINE = "DRAGONGLASS_MENU_DEFINE";

/** Forces reset of cached menu definitions */
export const DRAGONGLASS_MENU_RESET = "DRAGONGLASS_MENU_RESET";

export const defineMenu = (menu) => ({
  type: DRAGONGLASS_MENU_DEFINE,
  payload: menu,
});

export const resetMenu = () => ({
  type: DRAGONGLASS_MENU_RESET,
});
