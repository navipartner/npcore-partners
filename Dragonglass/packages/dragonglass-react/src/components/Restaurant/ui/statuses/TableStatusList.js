import { bindComponentToRestaurantTableStatusesState } from "../../../../redux/reducers/restaurantReducer";
import { npreWorkflows } from "../../npreWorkflows";
import { RestaurantStatusList } from "./RestaurantStatusList";

class TableStatusList extends RestaurantStatusList {
    click(e, statusId) {
        if (this.props.activeTable) {
            npreWorkflows.setTableStatus(this.props.activeTable, statusId);
            this.props.setStatus(this.props.activeTable, statusId);
        }
    }
}

export default bindComponentToRestaurantTableStatusesState(TableStatusList);
