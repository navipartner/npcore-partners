import React from "react";
import { useSelector } from "react-redux";
import { relativePageIndex } from "../../../../redux/mobile/mobile-selectors";

export default ({ defaultIndex, count }) => {
  const currentPage = useSelector(relativePageIndex);
  const width = window.innerWidth / count;
  const left = width * (defaultIndex + currentPage);

  return (
    <div style={{ width, left }} className="nav__active-item-indicator"></div>
  );
};
