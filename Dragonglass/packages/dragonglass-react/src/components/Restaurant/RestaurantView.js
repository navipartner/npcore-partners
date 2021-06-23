import React, { Component } from "react";
import SimpleButton from "../SimpleButton";
import { Popup } from "./../../dragonglass-popup/PopupHost";
import RestaurantActiveLocation from "./RestaurantActiveLocation";
import { StateStore } from "../../redux/StateStore";
import { transformComponentToBlob } from "../../classes/TransformSeating";
import { npreWorkflows } from "./npreWorkflows";

const processResult = (restaurantId, result, locations, components) => {
  const content = {};

  function transformLocation(location) {
    const result = { restaurantId };
    result.id = location.id;
    result.caption = location.caption;
    return result;
  }

  function updateContent(operation, type, item) {
    if (!content[operation]) content[operation] = {};

    if (!content[operation][type]) content[operation][type] = [];

    content[operation][type].push(item);
  }

  function processCollection(
    type,
    newCollection,
    originalCollection,
    transform
  ) {
    for (let item of newCollection) {
      let existingComponent = originalCollection.find((c) => c.id === item.id);
      if (existingComponent) {
        // Maybe modified
        if (JSON.stringify(item) !== JSON.stringify(existingComponent))
          updateContent("modify", type, transform(item));
      } else {
        // New
        updateContent("new", type, transform(item));
      }
    }

    for (let component of originalCollection) {
      if (!newCollection.find((c) => c.id === component.id)) {
        // Deleted
        updateContent("delete", type, component.id);
      }
    }
  }

  processCollection(
    "components",
    result.components,
    components,
    transformComponentToBlob
  );
  processCollection(
    "locations",
    result.locations,
    locations,
    transformLocation
  );

  return content;
};

class RestaurantView extends Component {
  async _edit() {
    const {
      locations,
      activeRestaurant,
      activeLocation,
    } = StateStore.getState().restaurant;
    if (!activeRestaurant) return;

    const restLocations = locations.filter(
      (l) => l.restaurantId === activeRestaurant
    );
    const components = [];
    for (let location of restLocations) {
      for (let component of location.components) {
        components.push({ ...component, location: location.id });
      }
    }

    const result = await Popup.seatingSetup({
      layout: { locations: restLocations, components },
      location: activeLocation,
    });
    if (!result) return;

    const content = processResult(
      activeRestaurant,
      result,
      restLocations,
      components
    );
    if (!content.new && !content.modify && !content.delete) return;

    npreWorkflows.saveLayout(content);
  }

  render() {
    const { showWaiterPads, editable, showTableWaiterPads } = this.props.layout;

    return (
      <div className="restaurant__container">
        {editable ? (
          <SimpleButton
            className="button--simple--edit"
            caption="Edit"
            onClick={() => this._edit()}
          />
        ) : null}
        <RestaurantActiveLocation
          showWaiterPads={showWaiterPads}
          showTableWaiterPads={showTableWaiterPads}
        />
      </div>
    );
  }
}

export default RestaurantView;
