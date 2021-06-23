import React, { PureComponent } from "react";
import { bindComponentToRestaurantActiveRestaurantState } from "../../redux/reducers/restaurantReducer";

class RestaurantSelectionItem extends PureComponent {
    click(e) {
        if (this.props.active)
            return;

        this.props.onSelect(this.props.restaurant.id);
        e.stopPropagation();
    }

    render() {
        const { restaurant, active } = this.props;

        return (
            <div className={`restaurant__selection__item ${active ? "is-active" : ""}`} onClick={e => this.click(e)}>{restaurant.caption}</div>
        );
    }
}

export default bindComponentToRestaurantActiveRestaurantState(RestaurantSelectionItem);
