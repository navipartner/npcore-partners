import { npreWorkflows } from "../../components/Restaurant/npreWorkflows";
import {
    DRAGONGLASS_RESTAURANT_DEFINE_LAYOUT,
    DRAGONGLASS_RESTAURANT_SELECT_LOCATION,
    DRAGONGLASS_RESTAURANT_SELECT_WAITERPAD,
    DRAGONGLASS_RESTAURANT_SELECT_RESTAURANT,
    DRAGONGLASS_RESTAURANT_DEFINE_WAITERPADS,
    DRAGONGLASS_RESTAURANT_UPDATE_STATUS,
    DRAGONGLASS_RESTAURANT_SELECT_TABLE,
    DRAGONGLASS_RESTAURANT_DEFINE_STATUSES,
    DRAGONGLASS_RESTAURANT_UPDATE_GUESTS
} from "./restaurantActionTypes";

export const restaurantDefineLayoutAction = locations => ({
    type: DRAGONGLASS_RESTAURANT_DEFINE_LAYOUT,
    payload: locations
});

export const restaurantSetRestaurantAction = restaurant => ({
    type: DRAGONGLASS_RESTAURANT_SELECT_RESTAURANT,
    payload: restaurant
});

export const restaurantSetLocationAction = location => ({
    type: DRAGONGLASS_RESTAURANT_SELECT_LOCATION,
    payload: location
});

export const restaurantDefineWaiterPadsAction = data => ({
    type: DRAGONGLASS_RESTAURANT_DEFINE_WAITERPADS,
    payload: data
});

export const restaurantSetWaiterPadAction = pad => {
    npreWorkflows.selectWaiterPad(pad);
    return {
        type: DRAGONGLASS_RESTAURANT_SELECT_WAITERPAD,
        payload: pad
    };
};

export const restaurantUpdateStatusAction = payload => ({
    type: DRAGONGLASS_RESTAURANT_UPDATE_STATUS,
    payload
});

export const restaurantSelectTableAction = id => ({
    type: DRAGONGLASS_RESTAURANT_SELECT_TABLE,
    payload: id
});

export const restaurantDefineStatuses = (table, waiterPad) => ({
    type: DRAGONGLASS_RESTAURANT_DEFINE_STATUSES,
    payload: { table, waiterPad }
});

export const restaurantUpdateGuests = (table, guests) => ({
    type: DRAGONGLASS_RESTAURANT_UPDATE_GUESTS,
    payload: { table, guests }
});
