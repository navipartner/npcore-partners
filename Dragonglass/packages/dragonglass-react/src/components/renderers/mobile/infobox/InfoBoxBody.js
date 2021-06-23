import React from "react";
import { InfoBoxRow } from "./InfoBoxRow";

export const InfoBoxBody = ({ rows }) => {
  if (!rows || !rows.length) {
    return null;
  }
  return (
    <div className="infobox__body">
      {rows.map((row, index) => (
        <InfoBoxRow row={row} key={index} />
      ))}
    </div>
  );
};
