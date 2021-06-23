import React from "react";
import { DataSourceContext } from "../../../../dragonglass-context";
import { InfoBoxFooter } from "./InfoBoxFooter";
import { InfoBoxBody } from "./InfoBoxBody";
import { InfoBoxHeader } from "./InfoBoxHeader";

export const InfoBox = ({ layout }) => {
  const { header, rows, footer } = layout;
  return (
    <DataSourceContext.Provider value={layout.dataSource || null}>
      <div className="infobox">
        <InfoBoxHeader {...header} />
        <InfoBoxBody rows={rows} />
        <InfoBoxFooter {...footer} />
      </div>
    </DataSourceContext.Provider>
  );
};
