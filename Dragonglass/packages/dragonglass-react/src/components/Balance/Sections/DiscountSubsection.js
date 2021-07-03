import React from "react";
import { localize } from "../../LocalizationManager";

export default function DiscountSubsection({ layout, data }) {
  const discountLabels = layout.filter((item) => item.select === "discountAmounts")[0]; //TODO: set up new proper labels
  const percents = Object.entries(data.discountPercent).sort((a, b) => a[0].localeCompare(b[0]));
  const discountAmounts = Object.entries(data.discountAmounts);
  const totalIsOddRow = discountAmounts.length % 2 === 0;

  return (
    <div className="subsection subsection--discount">
      <div className="subsection__discount-row subsection__discount-row--heading">
        <div className="subsection__label">Discount type</div>
        <div className="subsection__value-cell">Amount</div>
        <div className="subsection__value-cell">Percent</div>
      </div>
      {discountAmounts
        .sort((a, b) => a[0].localeCompare(b[0]))
        .map((item, index) => {
          const label = discountLabels.fields.filter((field) => field.select === item[0])[0].label;
          const localizedLabel = localize(label);
          const amount = item[1];
          const percent = percents[index][1];
          const isOddRow = index % 2 === 0;

          return (
            <div
              key={index}
              className={`subsection__discount-row ${isOddRow ? "subsection__discount-row--highlight" : ""}`}
            >
              <div className="subsection__label">{localizedLabel}</div>
              <div className="subsection__value-cell">{amount}</div>
              <div className="subsection__value-cell">{percent}</div>
            </div>
          );
        })}
      <div
        className={`subsection__discount-row subsection__discount-row--total ${
          totalIsOddRow ? "subsection__discount-row--highlight" : ""
        }`}
      >
        <div className="subsection__label subsection__label--total">Total</div>
        <div className="subsection__value-cell">{data.discountTotal.totalDiscountLcy}</div>
        <div className="subsection__value-cell">{data.discountTotal.totalDiscountPct}</div>
      </div>
    </div>
  );
}
