import React from "react";

export const SeatingSetupMenuButton = (props) => (
  <div
    className="seating-setup-menu-button"
    onClick={(e) => {
      props.onClick();
      e.stopPropagation();
    }}
  >
    <span className={props.icon ? `fa ${props.icon}` : ""}></span>
    <span>{props.caption}</span>
  </div>
);
