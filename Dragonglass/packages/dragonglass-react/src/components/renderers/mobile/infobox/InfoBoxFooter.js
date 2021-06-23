import React from "react";
import { InfoBoxContent } from "./InfoBoxContent";

export const InfoBoxFooter = ({ caption, field, align }) => {
  if (!caption && !field) {
    return null;
  }

  return (
    <div className="infobox__footer">
      <InfoBoxContent {...{ caption, field, align }} />
    </div>
  );
};
