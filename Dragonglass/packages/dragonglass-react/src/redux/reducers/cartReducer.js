import { createReducer } from "dragonglass-redux";
import initialState from "../initialState.js";
import {
    DRAGONGLASS_CART_SHOW
} from "../actions/cartActionTypes";
import { showCartAction } from "../actions/cartActions.js";
import { bindToMap } from "../reduxHelper.js";

const cart = createReducer(initialState.cart, {
    [DRAGONGLASS_CART_SHOW]: (state, payload) => state.visible === !!payload ? state : { ...state, visible: !!payload }
});

export default cart;

const cartMap = {
    state: state => ({ cartVisible: state.cart.visible }),
    dispatch: dispatch => ({
        showCart: visible => dispatch(showCartAction(visible)),
    })
};

export const bindComponentToCartState = component => bindToMap(component, cartMap);
