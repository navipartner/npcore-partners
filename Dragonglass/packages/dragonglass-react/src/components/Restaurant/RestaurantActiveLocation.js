import React, { PureComponent } from "react";
import { bindComponentToRestaurantActiveLocationState } from "../../redux/reducers/restaurantReducer";
import RestaurantLocation from "./RestaurantLocation";

class RestaurantActiveLocation extends PureComponent {
    render() {
        const { locationId, restaurantId, showTableWaiterPads } = this.props;
        return (
            <RestaurantLocation showTableWaiterPads={showTableWaiterPads} restaurantId={restaurantId} locationId={locationId} />
        );
    }
}

export default bindComponentToRestaurantActiveLocationState(RestaurantActiveLocation);
