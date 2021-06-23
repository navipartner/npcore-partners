import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper.js";
import initialState from "../initialState.js";
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
} from "../actions/restaurantActionTypes.js";
import {
    restaurantSetLocationAction,
    restaurantSetWaiterPadAction,
    restaurantSetRestaurantAction,
    restaurantUpdateStatusAction,
    restaurantUpdateGuests
} from "../actions/restaurantActions.js";

const restaurant = createReducer(initialState.restaurant, {
    [DRAGONGLASS_RESTAURANT_DEFINE_LAYOUT]: (state, payload) => ({ ...state, ...payload }),

    [DRAGONGLASS_RESTAURANT_SELECT_RESTAURANT]: (state, id) => {
        const newState = { ...state, activeRestaurant: id };
        if (!state.lastLocation[id]) {
            const locations = state.locations.filter(l => l.restaurantId === id);
            newState.activeLocation = locations.length ? locations[0].id : null;
        } else {
            newState.activeLocation = state.lastLocation[id];
        }

        return newState;
    },

    [DRAGONGLASS_RESTAURANT_SELECT_LOCATION]: (state, id) => {
        const newState = { ...state, activeLocation: id, activeTable: null };
        const location = state.locations.find(l => l.id === id);
        if (location && location.restaurantId) {
            newState.lastLocation = { ...newState.lastLocation };
            newState.lastLocation[location.restaurantId] = id;
        }
        return newState;
    },

    [DRAGONGLASS_RESTAURANT_DEFINE_WAITERPADS]: (state, payload) => ({ ...state, ...payload }),

    [DRAGONGLASS_RESTAURANT_SELECT_WAITERPAD]: (state, pad) => {
        const activeWaiterPad = pad === state.activeWaiterPad ? null : pad;
        const newState = { ...state, activeWaiterPad };
        if (state.activeTable) {
            const waiterPad = state.waiterPads.find(wp => wp.id === activeWaiterPad);
            if (!waiterPad.tables.includes(state.activeTable) && waiterPad.tables.length)
                newState.activeTable = waiterPad.tables[0];
        }

        return newState;
    },

    [DRAGONGLASS_RESTAURANT_UPDATE_STATUS]: (state, payload) => {
        const oldTableStatus = JSON.stringify(state.tableStatus), oldWaiterPadStatus = JSON.stringify(state.waiterPadStatus);
        const newTableStatus = JSON.stringify(payload.seating), newWaiterPadStatus = JSON.stringify(payload.waiterPad);
        if (oldTableStatus === newTableStatus && oldWaiterPadStatus === newWaiterPadStatus)
            return state;

        const newState = { ...state };
        if (payload.seating)
            newState.tableStatus = { ...state.tableStatus, ...payload.seating };
        if (payload.waiterPad)
            newState.waiterPadStatus = { ...state.waiterPadStatus, ...payload.waiterPad };

        return newState;
    },

    [DRAGONGLASS_RESTAURANT_SELECT_TABLE]: (state, id) => {
        const newId = state.activeTable === id ? null : id;
        let lastTableWaiterPad = { ...state.lastTableWaiterPad };
        if (state.activeTable && state.activeWaiterPad)
            lastTableWaiterPad[state.activeTable] = state.activeWaiterPad;

        let activeWaiterPad = null;
        let waiterPad = null;
        if (newId !== null) {
            if (state.activeWaiterPad !== null) {
                waiterPad = state.waiterPads.find(wp => wp.id === state.activeWaiterPad);
                if (waiterPad !== null && waiterPad.tables.includes(newId))
                    activeWaiterPad = state.activeWaiterPad;
            }

            let lastWaiterPad = state.lastTableWaiterPad[newId];
            if (activeWaiterPad === null) {
                if (lastWaiterPad) {
                    waiterPad = state.waiterPads.find(wp => wp.id === lastWaiterPad);
                    if (waiterPad && waiterPad.tables.includes(newId))
                        activeWaiterPad = lastWaiterPad;
                } else {
                    waiterPad = state.waiterPads.find(wp => wp.tables.includes(newId));
                    if (waiterPad)
                        activeWaiterPad = waiterPad.id;
                }
            }
        }

        return { ...state, activeTable: newId, activeWaiterPad, lastTableWaiterPad };
    },

    [DRAGONGLASS_RESTAURANT_DEFINE_STATUSES]: (state, payload) => ({ ...state, statusesTable: payload.table, statusesWaiterPad: payload.waiterPad }),

    [DRAGONGLASS_RESTAURANT_UPDATE_GUESTS]: (state, payload) => {
        const oldGuests = state.numberOfGuests[payload.table];
        if (oldGuests === payload.guests)
            return state;

        return { ...state, numberOfGuests: { ...state.numberOfGuests, [payload.table]: payload.guests } };
    }
});

export default restaurant;

const sameRestaurant = (next, prev) => next.restaurant.activeRestaurant === prev.restaurant.activeRestaurant;
const sameLocation = (next, prev) => sameRestaurant(next, prev) && next.restaurant.activeLocation === prev.restaurant.activeLocation;
const sameTable = (next, prev) => sameLocation(next, prev) && next.restaurant.activeTable === prev.restaurant.activeTable;
const sameWaiterPad = (next, prev) => sameTable(next, prev) && next.restaurant.activeWaiterPad === prev.restaurant.activeWaiterPad;

const restaurantsMap = {
    state: state => ({ restaurants: state.restaurant.restaurants, activeRestaurant: state.restaurant.activeRestaurant }),
    dispatch: dispatch => ({
        setRestaurant: restaurant => dispatch(restaurantSetRestaurantAction(restaurant))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.restaurants === prev.restaurant.restaurants && next.restaurant.activeRestaurant === prev.restaurant.activeRestaurant
    }
};

const activeRestaurantMap = {
    state: (state, ownProps) => ({ active: state.restaurant.activeRestaurant === (ownProps.restaurant && ownProps.restaurant.id) }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.activeRestaurant === prev.restaurant.activeRestaurant
    }
};

const locationsMap = {
    state: state => ({ locations: state.restaurant.locations.filter(l => l.restaurantId === state.restaurant.activeRestaurant), activeLocation: state.restaurant.activeLocation }),
    dispatch: dispatch => ({
        setLocation: location => dispatch(restaurantSetLocationAction(location))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.locations === prev.restaurant.locations && next.restaurant.activeRestaurant === prev.restaurant.activeRestaurant && next.restaurant.activeLocation === prev.restaurant.activeLocation
    }
};

/**
 * This map provides active location ID rather than boolean flag whether a location is active. At any given moment, only the active location is
 * rendered, and this is handled through the <RestaurantActiveLocation> component, which will refresh only if active location changes, but not
 * on other state changes.
 */
const activeLocationMap = {
    state: state => ({ locationId: state.restaurant.activeLocation || null, restaurantId: state.restaurant.activeRestaurant || null }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.activeRestaurant === prev.restaurant.activeRestaurant && next.restaurant.activeLocation === prev.restaurant.activeLocation
    }
};

const locationMap = {
    state: (state, ownProps) => {
        if (!ownProps.locationId)
            return { location: null };

        const location = state.restaurant.locations.find(l => l.id === ownProps.locationId);
        return { location };
    },
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.locations === prev.restaurant.locations && next.restaurant.activeLocation === prev.restaurant.activeLocation
    }
};

const waiterPadsMap = {
    state: (state) => {
        if (!state.restaurant.activeRestaurant)
            return { waiterPads: [] };

        const waiterPads = state.restaurant.waiterPads.filter(w => w.restaurantId === state.restaurant.activeRestaurant);
        return { waiterPads };
    },
    dispatch: dispatch => ({
        selectWaiterPad: waiterPad => dispatch(restaurantSetWaiterPadAction(waiterPad))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.waiterPads === prev.restaurant.waiterPads
    }
};

const waiterPadsForTableMap = {
    state: (state, ownProps) => {
        if (!ownProps.tableId || !ownProps.restaurantId)
            return { waiterPads: [] };

        const waiterPads = state.restaurant.waiterPads.filter(w => w.restaurantId === ownProps.restaurantId && w.tables.includes(ownProps.tableId));
        return { waiterPads };
    },
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.waiterPads === prev.restaurant.waiterPads
    }
};

const waiterPadsForActiveTableMap = {
    state: (state) => {
        if (!state.restaurant.activeTable || !state.restaurant.activeRestaurant)
            return { waiterPads: [] };

        const waiterPads = state.restaurant.waiterPads.filter(w => w.restaurantId === state.restaurant.activeRestaurant && w.tables.includes(state.restaurant.activeTable));
        const { activeTable } = state.restaurant;
        return { waiterPads, activeTable };
    },
    enhancer: {
        areStatesEqual: (next, prev) => sameTable(next, prev) && next.restaurant.waiterPads === prev.restaurant.waiterPads
    }
};

const activeTableMap = {
    state: (state) => {
        const location = state.restaurant.locations.find(location => location.id === state.restaurant.activeLocation);
        const table = location && location.components && location.components.find(component => component.id === state.restaurant.activeTable) || null;
        return { table };
    },
    enhancer: {
        areStatesEqual: (next, prev) => sameTable(next, prev)
    }
};

const activeWaiterPadMap = {
    state: (state, ownProps) => ({ active: state.restaurant.activeWaiterPad === (ownProps.pad && ownProps.pad.id) }),
    dispatch: dispatch => ({
        selectWaiterPad: waiterPad => dispatch(restaurantSetWaiterPadAction(waiterPad))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => sameWaiterPad(next, prev)
    }
};

const tableAdditionalStateMap = {
    state: (state, ownProps) => {
        const tableState = {};

        if (!ownProps.tableId)
            return tableState;

        const tableStatus = state.restaurant.tableStatus[ownProps.tableId];
        tableState.status = null;
        if (tableStatus) {
            const status = state.restaurant.statusesTable.find(status => status.id === tableStatus);
            if (status)
                tableState.status = status;
        }

        return { tableState };
    }
}

const waiterPadAdditionalStateMap = {
    state: (state, ownProps) => {
        const waiterPadState = {};

        if (!ownProps.pad || !ownProps.pad.id)
            return waiterPadState;

        const waiterPadStatus = state.restaurant.waiterPadStatus[ownProps.pad.id];
        waiterPadState.status = null;
        if (waiterPadStatus) {
            const status = state.restaurant.statusesWaiterPad.find(status => status.id === waiterPadStatus);
            if (status)
                waiterPadState.status = status;
        }

        return { waiterPadState };
    }
}

const statusesWaiterPadMap = {
    state: state => ({ statuses: state.restaurant.statusesWaiterPad, bound: !!state.restaurant.activeWaiterPad, active: state.restaurant.waiterPadStatus[state.restaurant.activeWaiterPad] || null, activeWaiterPad: state.restaurant.activeWaiterPad }),
    dispatch: dispatch => ({
        setStatus: (id, status) => dispatch(restaurantUpdateStatusAction({ waiterPad: { [id]: status } }))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.statusesWaiterPad === prev.restaurant.statusesWaiterPad && sameWaiterPad(next, prev) && next.restaurant.waiterPadStatus === prev.restaurant.waiterPadStatus
    }
};

const statusesTableMap = {
    state: state => ({ statuses: state.restaurant.statusesTable, bound: !!state.restaurant.activeTable, active: state.restaurant.tableStatus[state.restaurant.activeTable] || null, activeTable: state.restaurant.activeTable }),
    dispatch: dispatch => ({
        setStatus: (id, status) => dispatch(restaurantUpdateStatusAction({ seating: { [id]: status } }))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.statusesTable === prev.restaurant.statusesTable && next.restaurant.activeTable === prev.restaurant.activeTable && next.restaurant.tableStatus === prev.restaurant.tableStatus
    }
};

const numberOfGuestsMap = {
    state: state => ({ numberOfGuests: (state.restaurant.activeTable ? state.restaurant.numberOfGuests[state.restaurant.activeTable] : 0) || 0, activeTable: state.restaurant.activeTable, activeWaiterPad: state.restaurant.activeWaiterPad }),
    dispatch: dispatch => ({
        updateGuests: (id, guests) => dispatch(restaurantUpdateGuests(id, guests))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.numberOfGuests === prev.restaurant.numberOfGuests && sameTable(prev, next) && sameWaiterPad(prev, next)
    }
};

const numberOfGuestsAtTableMap = {
    state: (state, ownProps) => ({ numberOfGuests: (ownProps.tableId ? state.restaurant.numberOfGuests[ownProps.tableId] : 0) || 0 }),
    enhancer: {
        areStatesEqual: (next, prev) => next.restaurant.numberOfGuests === prev.restaurant.numberOfGuests && next.restaurant.activeTable === prev.restaurant.activeTable
    }
};

/**
 * Binds a component to active restaurants state. This includes the list of all restaurants available, or empty array if there are none.
 * Attaches "restaurants" of type "object" (Array) to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantRestaurantsState = component => bindToMap(component, restaurantsMap);

/**
 * Binds a component to active restaurant state. This includes the boolean flag indicating whether the restaurant indicated by restaurant.id in component
 * properties is the currently active restaurant. Attaches "active" of type "boolean" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantActiveRestaurantState = component => bindToMap(component, activeRestaurantMap);

/**
 * Binds a component to all locations state. This includes the array of all available locations. Attaches "locations" of type "object" (Array) 
 * to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantLocationsState = component => bindToMap(component, locationsMap);

/**
 * Binds a component to active location state. This includes the ID (string) of the currently active location, or null if empty. Attaches 
 * "locationId" of type "string" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantActiveLocationState = component => bindToMap(component, activeLocationMap);

/**
 * Binds a component to a single location state. This includes the object defining active location, or null if no such location exists. Uses 
 * the "locationId" of type "string" from this.props to find a matching location in state, and attaches "location" of type "object" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantLocationState = component => bindToMap(component, locationMap);

/**
 * Binds a component to waiter pads state. This includes the list of all waiter pads for the active restaurant, or empty array if there are none.
 * Attaches "waiterPads" of type "object" (Array) to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToWaiterPadsListState = component => bindToMap(component, waiterPadsMap);

/**
 * Binds a component to waiter pads per-table state. This includes all waiter pads that have a relationship to the specified table, or empty array
 * if there are none. Attaches "waiterPads" of type "object" (Array) to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToTableWaiterPadsList = component => bindToMap(component, waiterPadsForTableMap);

/**
 * Binds a component to waiter pads for active table state. This includes all waiter pads that have a relationship to the active table, or empty array
 * if there are none (or no table is active). Attaches "waiterPads" of type "object" (Array) to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToActiveTableWaiterPadsList = component => bindToMap(component, waiterPadsForActiveTableMap);

/**
 * Binds a component to active waiter pad state. This includes the boolean flag indicating whether the waiter pad indicated by pad.id in component
 * properties is the currently active waiter pad. Attaches "active" of type "boolean" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantActiveWaiterPadState = component => bindToMap(component, activeWaiterPadMap);

/**
 * Binds a component to additional table state. This includes any runtime or dynamic state, or in general anything that's not part of the static state
 * stored in restaurant layout in the back end. At minimum, this is actual table state, but may include more information, such as waiter name, etc.
 * Attaches "tableState" of type "object" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantAdditionalTableState = component => bindToMap(component, tableAdditionalStateMap);

/**
 * Binds a component to additional waiter pad state. This includes any runtime or dynamic state, or in general anything that's not part of the static state
 * stored in restaurant layout in the back end. At minimum, this is actual waiter pad state, but may include more information, such as waiter name, etc.
 * Attaches "waiterPadState" of type "object" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantAdditionalWaiterPadState = component => bindToMap(component, waiterPadAdditionalStateMap);

/**
 * Binds a component to table statuses state. This includes all table status configuration info back end reported as possible table statuses.
 * Attaches "statuses" of type "object" (Array) and "activeTarget" of type "string" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantTableStatusesState = component => bindToMap(component, statusesTableMap);

/**
 * Binds a component to waiter pad statuses state. This includes all waiter pad status configuration info back end reported as possible table statuses.
 * Attaches "statuses" of type "object" (Array) and "activeTarget" of type "string" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantWaiterPadStatusesState = component => bindToMap(component, statusesWaiterPadMap);

/**
 * Binds a component to active table state. This includes table info for the table that's marked as currently active.
 * Attaches "table" of type "object" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantActiveTableState = component => bindToMap(component, activeTableMap);

/**
 * Binds a component to number of guests for the active table state. This includes a number that indicates how many guests are present at the currently
 * active table. Attaches "numberOfGuests" of type "number" and "activeTable" of type "string" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantNumberOfGuestsState = component => bindToMap(component, numberOfGuestsMap);

/**
 * Binds a component to number of guests for the table specified in ownProps. This includes a number that indicates how many guests are present at the
 * specified table. Attaches "numberOfGuests" of type "number" to this.props.
 * @param {Component} component Component to bind
 */
export const bindComponentToRestaurantNumberOfGuestsAtTableState = component => bindToMap(component, numberOfGuestsAtTableMap);
