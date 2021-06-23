import React, { Component } from "react";
import { bindComponentToRestaurantLocationsState } from "../../redux/reducers/restaurantReducer";
import RestaurantLocationSelectionButton from "./RestaurantLocationSelectionButton";
import RestaurantSelection from "./RestaurantSelection";

class RestaurantLocationSelection extends Component {
  render() {
    const { locations, activeLocation, layout } = this.props;
    return (
      <>
        {layout.showRestaurant ? (
          <RestaurantSelection
            allowSelection={layout.allowRestaurantSelection}
          />
        ) : null}
        <div className="restaurant__locations">
          {locations.map((location, id) => (
            <RestaurantLocationSelectionButton
              key={id}
              location={location}
              active={location.id === activeLocation}
              onClick={() => this.props.setLocation(location.id)}
            />
          ))}
        </div>
      </>
    );
  }
}

export default bindComponentToRestaurantLocationsState(
  RestaurantLocationSelection
);
