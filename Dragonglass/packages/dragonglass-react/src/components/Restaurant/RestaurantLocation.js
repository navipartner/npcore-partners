import React, { PureComponent } from "react";
import { bindComponentToRestaurantLocationState } from "../../redux/reducers/restaurantReducer";
import { Floor } from "./ui/Floor";

class RestaurantLocation extends PureComponent {
  render() {
    const { location, restaurantId, showTableWaiterPads } = this.props;
    if (!location) return null;

    return (
      <div className="restaurant__location">
        <div className="restaurant__location__name">
          {location.caption || "(Unnamed location)"}
        </div>

        <Floor
          showTableWaiterPads={showTableWaiterPads}
          restaurantId={restaurantId}
          locationId={location.id}
          components={location.components || []}
        />
      </div>
    );
  }
}

export default bindComponentToRestaurantLocationState(RestaurantLocation);
