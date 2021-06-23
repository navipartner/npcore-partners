import React, { PureComponent } from "react";
import {
  bindComponentToRestaurantActiveWaiterPadState,
  bindComponentToRestaurantAdditionalWaiterPadState,
} from "../../redux/reducers/restaurantReducer";
import { getStatusColorAndIcon } from "./status";

class WaiterPad extends PureComponent {
  getStyle(status, filter) {
    const style = {};
    if (status && status.color) style.backgroundColor = status.color;

    if (filter) {
      if (filter.statuses && (!status || !filter.statuses.includes(status.id)))
        style.display = "none";
    }

    return style;
  }

  click(e) {
    if (typeof this.props.onClick !== "function") return;

    this.props.onClick(e);
    e.stopPropagation();
  }

  render() {
    const { pad, active, waiterPadState, filter } = this.props;
    const status = getStatusColorAndIcon(
      waiterPadState && waiterPadState.status
    );

    return (
      <div
        style={this.getStyle(status, filter)}
        className={`waiter-pads__pad ${active ? "is-active" : ""}`}
        onClick={(e) => this.click(e)}
      >
        {status && status.icon ? <span className={status.icon}></span> : null}
        {pad.caption}
      </div>
    );
  }
}

export default bindComponentToRestaurantAdditionalWaiterPadState(
  bindComponentToRestaurantActiveWaiterPadState(WaiterPad)
);
