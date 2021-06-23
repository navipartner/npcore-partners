import { bindComponentToRestaurantWaiterPadStatusesState } from "../../../../redux/reducers/restaurantReducer";
import { npreWorkflows } from "../../npreWorkflows";
import { RestaurantStatusList } from "./RestaurantStatusList";

class WaiterPadStatusList extends RestaurantStatusList {
    click(e, statusId) {
        if (this.props.activeWaiterPad) {
            npreWorkflows.setWaiterPadStatus(this.props.activeWaiterPad, statusId);
            this.props.setStatus(this.props.activeWaiterPad, statusId);
        }
    }
}

export default bindComponentToRestaurantWaiterPadStatusesState(WaiterPadStatusList);
