import React from "react";
import { InfoBoxContent } from "./InfoBoxContent";

export const InfoBoxHeader = ({ caption, field, align }) => {
  if (!caption && !field) {
    return null;
  }

  return (
    <div className="infobox__header">
      <InfoBoxContent {...{ caption, field, align }} />
    </div>
  );
};
