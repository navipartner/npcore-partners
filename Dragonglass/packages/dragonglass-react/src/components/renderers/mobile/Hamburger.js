import React from "react";
import { mobileActions } from "../../../redux/mobile/mobile-actions";

export const Hamburger = () => {
  return (
    <div
      className="toolbar__option toolbar__option--hamburger"
      onClick={() => mobileActions.showDrawer(true)}
    >
      <i className="fa-light fa-bars"></i>
    </div>
  );
};
