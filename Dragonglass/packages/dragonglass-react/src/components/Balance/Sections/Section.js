import React from "react";
import Subsection from "./Subsection";
import DiscountSubsection from "./DiscountSubsection";
import Caption from "../../Caption";
import TurnoverCharts from "./TurnoverCharts";
import DiscountChart from "./DiscountChart";
import { motion } from "framer-motion";

export default function Section({ layout, isSingle, data, index }) {
  const delay = index >= 0 ? 0.1 * (index + 2) : 0.15;

  const subsections =
    layout.select === "discount" ? (
      <DiscountSubsection layout={layout.subsections} data={data} />
    ) : (
      layout.subsections.map((subsectionLayout, index) => {
        const subsectionData = (data && data[subsectionLayout.select]) || data || {};
        return (
          <Subsection
            key={index}
            layout={subsectionLayout}
            isSingle={layout.subsections.length === 1}
            data={subsectionData}
          />
        );
      })
    );

  const isColumnContainerClass = layout.select === "turnover" && isSingle ? "section-container--column" : "";
  const showAllContainerClass = isSingle ? "" : "section-container--inline";
  const isColumnSectionClass = layout.select === "discount" ? "section--column" : "";
  const isInlineRowSection = layout.select === "discount" && !isSingle;

  return (
    <div
      className={`section-container ${isColumnContainerClass} ${showAllContainerClass} ${
        isInlineRowSection ? "section-container--inline-row" : ""
      }`}
    >
      <motion.div
        className={`section ${isSingle ? "section--single" : ""} ${isColumnSectionClass} ${
          isInlineRowSection ? "section--inline-row" : ""
        }`}
        initial={{ position: "relative", top: -40, opacity: 0 }}
        animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: delay } }}
        key={layout.title}
      >
        {!isSingle && (
          <h1>
            <Caption caption={layout.title} />
          </h1>
        )}
        <div className="subsection-container">{subsections}</div>
      </motion.div>
      {layout.select === "turnover" && (
        <TurnoverCharts
          layout={layout}
          data={data}
          height={isSingle ? 200 : 120}
          isSingle={isSingle}
          delay={delay + 0.1}
        />
      )}
      {layout.select === "discount" && (
        <DiscountChart
          layout={layout}
          data={data}
          delay={delay + 0.1}
          isSingle={isSingle}
          height={isSingle ? 200 : 110}
        />
      )}
    </div>
  );
}
