import React, { PureComponent } from "react";
import { bindComponentToDataSetState } from "../../redux/reducers/dataReducer";

class CartBadge extends PureComponent {
    render() {
        const { length } = this.props.data.rows.filter(row => !row.pending);

        return length
            ? <span className="cart-view__badge">{length}</span>
            : null;
    }
}

export default bindComponentToDataSetState(CartBadge);
