import { FrontEndAsyncRequest } from "../FrontEndAsyncRequest";
import { StateStore } from "../../redux/StateStore";
import { restaurantDefineWaiterPadsAction } from "../../redux/actions/restaurantActions";
import { Popup } from "../../dragonglass-popup/PopupHost";

export class UpdateWaiterPadContent extends FrontEndAsyncRequest {
    handle(request) {
        Popup.message("UpdateWaiterPadContent is not yet supported.");
    }
}
