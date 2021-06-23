import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../../redux/StateStore";
import { restaurantDefineWaiterPadsAction } from "../../../redux/actions/restaurantActions";

export class UpdateWaiterPadData extends FrontEndAsyncRequestHandler {
    handle(request) {
        const { waiterPads, waiterPadSeatingLinks, activeWaiterPad } = request.Content;
        for (let pad of waiterPads) {
            pad.tables = waiterPadSeatingLinks.filter(l => l.restaurantId === pad.restaurantId && l.waiterPadId === pad.id).map(link => link.seatingId);
        }

        const payload = { waiterPads };
        if (activeWaiterPad)
            payload.activeWaiterPad = activeWaiterPad;

        StateStore.dispatch(restaurantDefineWaiterPadsAction(payload));
    }
}
