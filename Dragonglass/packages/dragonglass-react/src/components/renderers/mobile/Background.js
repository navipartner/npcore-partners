import React from "react";
import { NAV } from "dragonglass-nav";
import { useSelector } from "react-redux";
import { relativePageIndex } from "../../../redux/mobile/mobile-selectors";

const DEFAULT_BACKGROUND = "retail_background.png";

export const Background = () => {
  const page = useSelector(relativePageIndex);
  const src = NAV.instance.mapPath(`Images/${DEFAULT_BACKGROUND}`);
  const left = `${-100 - page * 25}%`;

  return (
    <div className="background">
      <img style={{ left }} className="background__image" src={src} />
    </div>
  );
};
