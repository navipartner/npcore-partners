import { DRAGONGLASS_CART_SHOW } from "./cartActionTypes";

export const showCartAction = visible => ({
    type: DRAGONGLASS_CART_SHOW,
    payload: visible
});
