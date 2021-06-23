import React, { PureComponent } from "react";
import { bindComponentToRestaurantRestaurantsState } from "../../redux/reducers/restaurantReducer";
import RestaurantSelectionItem from "./RestaurantSelectionItem";
import { npreWorkflows } from "./npreWorkflows";

class RestaurantSelection extends PureComponent {
    constructor(props) {
        super(props);

        this.state = { menuActive: false };
    }

    click(e) {
        if (!this.props.allowSelection)
            return;

        this.setState({ menuActive: !this.state.menuActive })
    }

    switchRestaurant(restaurant) {
        if (!this.props.allowSelection)
            return;

        this.props.setRestaurant(restaurant);
        this.setState({ menuActive: false });
        npreWorkflows.selectRestaurant(restaurant);
    }

    render() {
        const { restaurants, activeRestaurant, allowSelection } = this.props;
        const restaurant = restaurants.find(r => r.id === activeRestaurant);

        return (
            <div className={`restaurant__selection${this.state.menuActive ? " is-active" : ""}`}>
                <div className={`restaurant__selection__current ${allowSelection ? "restaurant__selection__current--allow-selection" : ""}`} onClick={e => this.click(e)}>
                    {restaurant && restaurant.caption}
                    {allowSelection ? <span className="fat fa-angle-down"></span> : null}
                </div>
                <div className="restaurant__selection__list">
                    {restaurants.map((restaurant, id) => <RestaurantSelectionItem key={id} restaurant={restaurant} onSelect={restaurant => this.switchRestaurant(restaurant)} />)}
                </div>
            </div>
        );
    }
}

export default bindComponentToRestaurantRestaurantsState(RestaurantSelection);
