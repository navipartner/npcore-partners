import React, { PureComponent } from "react";
import { npreWorkflows } from "../npreWorkflows";
import { bindComponentToActiveTableWaiterPadsList } from './../../../redux/reducers/restaurantReducer';
import TableWaiterPad from "./TableWaiterPad";

class ActiveTableWaiterPads extends PureComponent {
    render() {
        const { waiterPads, activeTable } = this.props;

        return (
            /*
                TODO Vladimir:
                - className on the root of the component
                - layout should always be horizontal, never vertical (waiter pads side-by-side, rather than one above another)
            */
            <div className="table-waiter-pads">
                {waiterPads.map((pad, id) => <TableWaiterPad pad={pad} key={id} />)}
                <div className="table-waiter-pad" onClick={() => npreWorkflows.newWaiterPad(activeTable)}>+</div>
            </div>
        );
    }
}

export default bindComponentToActiveTableWaiterPadsList(ActiveTableWaiterPads);