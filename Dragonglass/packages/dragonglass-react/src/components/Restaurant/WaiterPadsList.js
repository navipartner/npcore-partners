import React, { PureComponent } from "react";
import { bindComponentToWaiterPadsListState } from "./../../redux/reducers/restaurantReducer";
import WaiterPad from "./WaiterPad";

class WaiterPadsList extends PureComponent {
  render() {
    const { waiterPads, layout } = this.props;

    return (
      <div className="waiter-pads">
        {waiterPads.map((pad, id) => (
          <WaiterPad
            pad={pad}
            key={id}
            filter={layout.filter}
            onClick={() => this.props.selectWaiterPad(pad.id)}
          />
        ))}
      </div>
    );
  }
}

export default bindComponentToWaiterPadsListState(WaiterPadsList);
