import React from "react";
import { motion } from "framer-motion";
import Subsection from "./Subsection";

export default function BalancingSection({ layout, isSingle, data, activeSection }) {
  return (
    <motion.div
      className={`section section--balancing ${isSingle ? "section--single" : ""}`}
      initial={{ position: "relative", top: -40, opacity: 0 }}
      animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: 0.1 } }}
      key={activeSection}
    >
      <div className="subsection-container">
        {layout.subsections.map((subsectionLayout, index) => {
          const subsectionData = (data && data[subsectionLayout.select]) || data || {};
          return (
            <Subsection
              key={index}
              layout={subsectionLayout}
              isSingle={layout.subsections.length === 1}
              data={subsectionData}
            />
          );
        })}
      </div>
    </motion.div>
  );
}
