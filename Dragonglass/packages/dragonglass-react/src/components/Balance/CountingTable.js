import React from "react";
import { localize } from "../LocalizationManager";
import { motion } from "framer-motion";

export default function CountingTable({ layout, data, displayCoinTypes }) {
  return (
    <motion.div
      className="counting__section"
      initial={{ position: "relative", top: -40, opacity: 0 }}
      animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1] } }}
    >
      <div className="counting__row counting__row--heading">
        {layout.map((column, index) => {
          const localizedLabel = localize(column.label);
          return (
            <div
              className={`counting__cell ${column.alignRight ? "align-right" : ""}`}
              title={localizedLabel}
              key={index}
            >
              {localizedLabel}
            </div>
          );
        })}
        <div className="counting__cell"></div>
      </div>
      {data.map((row, index) => {
        const isOddRow = index % 2 === 0;

        return (
          <div className={`counting__row ${isOddRow ? "counting__row--highlight" : ""}`} key={index}>
            {layout.map((column, index) => {
              const value = row[column.select];

              return (
                <div className={`counting__cell ${typeof value === "number" ? "align-right" : ""}`} key={index}>
                  {value}
                </div>
              );
            })}
            <div className="counting__cell counting__cell--button">
              <div className="button" onClick={() => displayCoinTypes()}>
                {localize("Balancing_CashCountCountCoinTypes")}
              </div>
            </div>
          </div>
        );
      })}
    </motion.div>
  );
}
