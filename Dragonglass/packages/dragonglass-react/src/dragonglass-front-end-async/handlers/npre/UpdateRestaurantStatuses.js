import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../../redux/StateStore";
import { restaurantUpdateStatusAction } from "../../../redux/actions/restaurantActions";

export class UpdateRestaurantStatuses extends FrontEndAsyncRequestHandler {
    handle(request) {
        const { seating, waiterPad } = request.Content;

        const payload = {};
        if (seating) {
            payload.valid = true;
            payload.seating = seating;
        }

        if (waiterPad) {
            payload.valid = true;
            payload.waiterPad = waiterPad;
        }

        if (payload.valid)
            StateStore.dispatch(restaurantUpdateStatusAction(payload));
    }
}
