import React, { Component } from "react";
import { Chair } from "./Chair";
import TableWaiterPads from "./TableWaiterPads";
import { StateStore } from "../../../redux/StateStore";
import { restaurantSelectTableAction } from "./../../../redux/actions/restaurantActions";
import { bindComponentToRestaurantAdditionalTableState } from "../../../redux/reducers/restaurantReducer";
import { getStatusColorAndIcon } from "../status";
import NumberOfGuestsAtTable from "./NumberOfGuestsAtTable";
import { npreWorkflows } from "../npreWorkflows";

class Table extends Component {
  getStyle(status) {
    const { component } = this.props;
    const style = {
      width: `${60 * (component.width || 1)}px`,
      height: `${60 * (component.height || 1)}px`,
    };
    if (component.rotation) style.transform = `rotate(${component.rotation}deg)`;
    if (status && status.color) style.backgroundColor = status.color;
    if (component.color) style.backgroundColor = component.color; // A color specified directly on a component must "overwrite" a color defined in status

    return style;
  }

  getCaptionStyle() {
    const { component } = this.props;
    const style = {};
    if (component.rotation) style.transform = `rotate(-${component.rotation}deg)`;
    return style;
  }

  async click() {
    const noopSymbol = Symbol();
    const result = await npreWorkflows.selectTable(this.props.component.id, noopSymbol);
    if (result === noopSymbol) StateStore.dispatch(restaurantSelectTableAction(this.props.component.id));
  }

  render() {
    const { component, restaurantId, locationId, showWaiterPads, tableState } = this.props;
    const status = getStatusColorAndIcon(tableState && tableState.status);
    const chairs = (component.chairs && component.chairs.count) || 0;
    const color = component.color;
    return (
      <>
        {showWaiterPads ? (
          <TableWaiterPads restaurantId={restaurantId} locationId={locationId} tableId={component.id} />
        ) : null}
        <div
          style={this.getStyle(status)}
          className={`${`chairs-${chairs}`} table${component.round ? " table--round" : ""}`}
          onClick={(e) => this.click(e)}
        >
          <NumberOfGuestsAtTable tableId={component.id} />
          {status && status.icon ? <span className={`table__icon ${status.icon}`}></span> : null}
          <span className="table__caption" style={this.getCaptionStyle()}>
            {component.caption}
          </span>
          <Chair chairs={chairs} />
        </div>
      </>
    );
  }
}

export default bindComponentToRestaurantAdditionalTableState(Table);
