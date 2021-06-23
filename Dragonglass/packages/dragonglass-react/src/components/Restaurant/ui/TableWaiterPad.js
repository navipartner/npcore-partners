import React, { PureComponent } from "react";
import {
  bindComponentToRestaurantActiveWaiterPadState,
  bindComponentToRestaurantAdditionalWaiterPadState,
} from "../../../redux/reducers/restaurantReducer";
import { getStatusColorAndIcon } from "../status";

class TableWaiterPad extends PureComponent {
  getStyle(status) {
    const style = {};
    if (status && status.color) style.backgroundColor = status.color;

    return style;
  }

  click(e) {
    const { selectWaiterPad, pad } = this.props;
    selectWaiterPad(pad.id);
    e.stopPropagation();
  }

  render() {
    const { pad, active, waiterPadState } = this.props;
    const status = getStatusColorAndIcon(
      waiterPadState && waiterPadState.status
    );

    return (
      <div
        style={this.getStyle(status)}
        className={`table-waiter-pad ${active ? "is-active" : ""}`}
        onClick={(e) => this.click(e)}
      >
        {status && status.icon ? <span className={status.icon}></span> : null}
        {pad.caption}
      </div>
    );
  }
}

export default bindComponentToRestaurantAdditionalWaiterPadState(
  bindComponentToRestaurantActiveWaiterPadState(TableWaiterPad)
);
