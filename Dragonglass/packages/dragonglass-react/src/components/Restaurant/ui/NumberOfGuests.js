import React, { PureComponent } from "react";
import PlusMinusEditor from "./../../PlusMinusEditor";
import { bindComponentToRestaurantNumberOfGuestsState } from "../../../redux/reducers/restaurantReducer";
import { npreWorkflows } from "../npreWorkflows";

class NumberOfGuests extends PureComponent {
    updateNumberOfGuests(increase) {
        const { activeTable, activeWaiterPad, numberOfGuests } = this.props;
        
        npreWorkflows.setNumberOfGuests(activeTable, activeWaiterPad, numberOfGuests + increase)
        this.props.updateGuests(activeTable, numberOfGuests + increase);
    }

    render() {
        return <PlusMinusEditor caption="Number of guests" passive={true} value={this.props.numberOfGuests} minValue={0} maxValue={8} updater={value => this.updateNumberOfGuests(value)} />
    }
}

export default bindComponentToRestaurantNumberOfGuestsState(NumberOfGuests);
