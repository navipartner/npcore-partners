import React from "react";
import { motion } from "framer-motion";
import { localize } from "../../LocalizationManager";

export default function TaxSummary({ layout, isSingle, data }) {
  return (
    <motion.div
      className={`section section--tax ${isSingle ? "section--single" : ""}`}
      initial={{ position: "relative", top: -40, opacity: 0 }}
      animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: isSingle ? 0.15 : 0.1 } }}
    >
      {!isSingle && <h1>{localize("Balancing_TaxSummary")}</h1>}
      <div className="tax-summary">
        <div className="tax-summary__row tax-summary__row--heading">
          {layout.map((headingCell, index) => {
            return (
              <div className="tax-summary__cell" key={index}>
                {localize(headingCell.label)}
              </div>
            );
          })}
        </div>
        {data.map((row, index) => {
          const isOddRow = index % 2 === 0;

          return (
            <div className={`tax-summary__row ${isOddRow ? "tax-summary__row--highlight" : ""}`} key={index}>
              {layout.map((column, index) => {
                return (
                  <div className="tax-summary__cell" key={index}>
                    {row[column.select]}
                  </div>
                );
              })}
            </div>
          );
        })}
      </div>
    </motion.div>
  );
}
