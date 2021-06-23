import React from "react";
import { useSelector } from "react-redux";
import { selectedToolbarOption } from "../../../../redux/mobile/mobile-selectors";
import { MOBILE_BUTTON_VIEW } from "../mobileConstants";
import MenuBody from "./MenuBody";

export const Menu = ({ layout, clickHandler }) => {
  const view = useSelector(selectedToolbarOption) || MOBILE_BUTTON_VIEW.LIST;

  return (
    <div className="menu">
      <MenuBody
        clickHandler={clickHandler}
        layout={layout}
        view={view}
        flat={true}
      />
    </div>
  );
};
