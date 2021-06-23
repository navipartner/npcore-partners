import React, { PureComponent } from "react";
import { bindComponentToTableWaiterPadsList } from "../../../redux/reducers/restaurantReducer";
import TableWaiterPad from "./TableWaiterPad";

class TableWaiterPads extends PureComponent {
  render() {
    const { waiterPads } = this.props;
    return (
      <div className="table-waiter-pads">
        {waiterPads.map((pad, key) => (
          <TableWaiterPad key={key} pad={pad} />
        ))}
      </div>
    );
  }
}

export default bindComponentToTableWaiterPadsList(TableWaiterPads);
