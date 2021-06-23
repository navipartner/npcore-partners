import React from "react";
import { useSelector } from "react-redux";
import { mobileActions } from "../../../../redux/mobile/mobile-actions";
import { activePage } from "../../../../redux/mobile/mobile-selectors";
import { Badge } from "./Badge";

export default ({ index, icon, caption, disabled, page, badge }) => {
  const active = useSelector((state) => activePage(state, index));

  return (
    <button
      onClick={() => mobileActions.navigateTo({ index, subpage: page })}
      disabled={disabled}
      className={`nav__button ${active ? "is-active" : ""} ${
        disabled ? "nav__button--disabled" : ""
      }`}
    >
      <span className={`${active ? "fas" : "fat"} ${icon} nav__icon`}>
        {badge && <Badge {...badge} />}
      </span>
      <span className="nav__caption">{caption}</span>
    </button>
  );
};
