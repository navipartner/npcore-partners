import React from "react";
import { GridClickHandler } from "../../../dragonglass-click-handlers/grid/GridClickHandler";
import { createRipple } from "./createRipple";

const click = (event, button, clickHandler) => {
  createRipple(event);

  if (clickHandler && clickHandler instanceof GridClickHandler) {
    if (clickHandler.onClick(button, this)) return;
  }
};

export default function Button({ button, clickHandler }) {
  const backgroundColor = button.backgroundColor
    ? `mobile-button--${button.backgroundColor}`
    : "mobile-button--primary-mobile";

  return (
    <button
      disabled={!button.enabled}
      className={`mobile-button ${backgroundColor}`}
      onClick={(event) => click(event, button, clickHandler)}
    >
      <div className="mobile-button__icon">
        <i className={button.iconClass}></i>
      </div>
      <div className="mobile-button__caption">{button.caption}</div>
    </button>
  );
}
