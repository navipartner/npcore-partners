import React, { PureComponent } from "react";
import { bindComponentToRestaurantActiveTableState } from "../../../redux/reducers/restaurantReducer";

class TableInfo extends PureComponent {
    render() {
        const { table, layout } = this.props;
        return (
            <div className={`npre-table-info ${layout.class || ""}`}>
                {table ? table.caption : "(No table selected)"}
            </div>
        );
    }
}

export default bindComponentToRestaurantActiveTableState(TableInfo);
