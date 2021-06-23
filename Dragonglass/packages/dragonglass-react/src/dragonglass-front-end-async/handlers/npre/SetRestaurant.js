import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../../redux/StateStore";
import { restaurantSetRestaurantAction } from "../../../redux/actions/restaurantActions";

export class SetRestaurant extends FrontEndAsyncRequestHandler {
    handle(request) {
        const { restaurantId } = request.Content;
        StateStore.dispatch(restaurantSetRestaurantAction(restaurantId));
    }
}
