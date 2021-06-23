import React, { PureComponent } from "react";
import { bindComponentToMenuState } from "../../../../redux/menu/menu-selectors";
import Button from "../Button";
import { MOBILE_BUTTON_VIEW } from "../mobileConstants";

const viewClassName = {
  [MOBILE_BUTTON_VIEW.LIST]: "list",
  [MOBILE_BUTTON_VIEW.COLUMNS]: "columns",
  [MOBILE_BUTTON_VIEW.GRID]: "grid",
  [MOBILE_BUTTON_VIEW.GRID_SMALL]: "grid-small",
};

const renderer = {
  [MOBILE_BUTTON_VIEW.LIST]: (menu, clickHandler) => {
    return menu.map((button, index) => (
      <Button key={index} button={button} clickHandler={clickHandler} />
    ));
  },

  [MOBILE_BUTTON_VIEW.COLUMNS]: (menu, clickHandler) => {
    return menu.map((button, index) => (
      <Button key={index} button={button} clickHandler={clickHandler} />
    ));
  },

  [MOBILE_BUTTON_VIEW.GRID]: (menu, clickHandler) => {
    return menu.map((button, index) => (
      <Button key={index} button={button} clickHandler={clickHandler} />
    ));
  },

  [MOBILE_BUTTON_VIEW.GRID_SMALL]: (menu, clickHandler) => {
    return menu.map((button, index) => (
      <Button key={index} button={button} clickHandler={clickHandler} />
    ));
  },
};

class Body extends PureComponent {
  render() {
    const { view, menu, clickHandler } = this.props;

    return (
      <div className={`layout-body layout-body--${viewClassName[view]}`}>
        {renderer[view](menu || [], clickHandler)}
      </div>
    );
  }
}

export default bindComponentToMenuState(Body);
