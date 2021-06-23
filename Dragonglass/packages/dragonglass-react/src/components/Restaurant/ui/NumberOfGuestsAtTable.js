import React, { PureComponent } from "react";
import { bindComponentToRestaurantNumberOfGuestsAtTableState } from "../../../redux/reducers/restaurantReducer";

class NumberOfGuestsAtTable extends PureComponent {
    render() {
        const { numberOfGuests } = this.props;

        return numberOfGuests
            ? <div className="number-of-guests"><span className="fa fa-user"></span> {this.props.numberOfGuests}</div>
            : null;
    }
}

export default bindComponentToRestaurantNumberOfGuestsAtTableState(NumberOfGuestsAtTable);
