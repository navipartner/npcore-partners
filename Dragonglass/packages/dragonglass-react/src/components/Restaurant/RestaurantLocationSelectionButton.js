import React, { PureComponent } from "react";
import SimpleButton from "./../SimpleButton";

export default class RestaurantLocationSelectionButton extends PureComponent {
  render() {
    const { location, onClick, active } = this.props;

    return (
      <div
        className={`restaurant__location__selection__button ${
          active ? "is-active" : ""
        }`}
      >
        <SimpleButton
          active={active}
          width={"160px"}
          height={"35px"}
          caption={location.caption}
          onClick={onClick}
        />
      </div>
    );
  }
}
