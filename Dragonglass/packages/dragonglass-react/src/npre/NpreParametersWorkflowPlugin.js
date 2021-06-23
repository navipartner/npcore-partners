import { WorkflowPlugin } from "dragonglass-workflows";
import { StateStore } from "../redux/StateStore";

export class NpreParametersWorkflowPlugin extends WorkflowPlugin {
    processParameters(parameters) {
        const state = StateStore.getState().restaurant;

        if (parameters.hasOwnProperty("RestaurantCode"))
            parameters.RestaurantCode = state.activeRestaurant;

        if (parameters.hasOwnProperty("WaiterPadCode"))
            parameters.WaiterPadCode = state.activeWaiterPad;

        if (parameters.hasOwnProperty("SeatingCode"))
            parameters.SeatingCode = state.activeTable;
    }   
}
