import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../../redux/StateStore";
import { restaurantDefineLayoutAction, restaurantDefineStatuses } from "../../../redux/actions/restaurantActions";
import { transformComponentFromBlob } from "../../../classes/TransformSeating";

export class UpdateRestaurantLayout extends FrontEndAsyncRequestHandler {
    handle(request) {
        const { restaurants, locations, statuses } = request.Content;
        for (let location of locations) {
            let components = location.components;
            location.components = [];
            for (let component of components) {
                location.components.push(transformComponentFromBlob(component));
            }
        }
        StateStore.dispatch(restaurantDefineLayoutAction({ restaurants, locations }));
        if (typeof statuses === "object" && Array.isArray(statuses.seating) && Array.isArray(statuses.waiterPad))
            StateStore.dispatch(restaurantDefineStatuses(statuses.seating, statuses.waiterPad));
    }
}
