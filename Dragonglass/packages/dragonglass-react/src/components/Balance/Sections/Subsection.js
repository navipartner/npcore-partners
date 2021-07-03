import React from "react";
import Caption from "../../Caption";
import { localize } from "../../LocalizationManager";

export default function Subsection({ layout, isSingle, data }) {
  return (
    <div className={`subsection ${isSingle ? "subsection--single" : ""}`}>
      {layout.title && (
        <h2>
          <Caption caption={layout.title} />
        </h2>
      )}
      <div className="subsection__field-container">
        {layout.fields.map((field, index) => {
          const localizedLabel = localize(field.label);

          return (
            <div className="subsection__field" key={index}>
              <div title={localizedLabel} className="subsection__label">
                {localizedLabel}
              </div>
              <div title={data[field.select]} className="subsection__value">
                {data[field.select] || 0}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
