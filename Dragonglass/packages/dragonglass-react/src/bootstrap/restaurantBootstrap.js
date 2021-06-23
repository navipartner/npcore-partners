import { GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { StateStore } from "../redux/StateStore";
import { restaurantSetRestaurantAction, restaurantSetLocationAction } from "../redux/actions/restaurantActions";
import { NAVEventFactory } from "dragonglass-nav";
import { Options } from "../classes/Options";
import { WorkflowPluginRepository } from "dragonglass-workflows";
import { NpreParametersWorkflowPlugin } from "../npre/NpreParametersWorkflowPlugin";
import restaurant from "../redux/reducers/restaurantReducer";
import { ButtonGridPluginRepository } from "../components/ButtonGridPluginRepository";
import { NpreWaiterPadGridEnablerPlugin } from "../npre/NpreWaiterPadGridEnablerPlugin";

let requestWaiterPadData;
let requestRestaurantLayout;

let lastOptions = {};

const listenToSetOptions = options => {
    if (options.npre_DefaultRestaurantId !== lastOptions.npre_DefaultRestaurantId) {
        lastOptions.npre_DefaultRestaurantId = options.npre_DefaultRestaurantId;
        StateStore.dispatch(restaurantSetRestaurantAction(lastOptions.npre_DefaultRestaurantId));
    }

    if (options.npre_DefaultLocationId !== lastOptions.npre_DefaultLocationId) {
        lastOptions.npre_DefaultLocationId = options.npre_DefaultLocationId;
        StateStore.dispatch(restaurantSetLocationAction(lastOptions.npre_DefaultLocationId));
    }
};

const listenToSetView = view => {
    if (view.type !== "restaurant")
        return;

    const { restaurantId: activeRestaurant, locationId: activeLocation } = StateStore.getState().restaurant;
    const restaurantId = activeRestaurant || Options.get("npre_DefaultRestaurantId") || "";
    const locationId = activeLocation || Options.get("npre_DefaultLocationId") || "";
    requestRestaurantLayout.raise({ restaurantId });
    requestWaiterPadData.raise({ restaurantId, locationId });
};

const initialize = () => {
    GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.SET_OPTIONS, listenToSetOptions);
    GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.SET_VIEW, listenToSetView);

    requestWaiterPadData = NAVEventFactory.method({ name: "RequestWaiterPadData", skipIfBusy: false }) || undefined;
    requestRestaurantLayout = NAVEventFactory.method({ name: "RequestRestaurantLayout", skipIfBusy: false }) || undefined;

    WorkflowPluginRepository.registerPlugin("npre-parameters", new NpreParametersWorkflowPlugin());
    ButtonGridPluginRepository.registerPlugin("npre-waiterpad-enabler", new NpreWaiterPadGridEnablerPlugin());
    StateStore.injectReducer("restaurant", restaurant);
};

export const RestaurantBootstrap = { initialize };
