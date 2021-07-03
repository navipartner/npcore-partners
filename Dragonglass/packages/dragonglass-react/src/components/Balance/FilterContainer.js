import React from "react";
import Filter from "./Filter";
import { motion, AnimateSharedLayout } from "framer-motion";
import { localize } from "../LocalizationManager";
import { SECTION_CONSTANTS } from "./Sections/SectionConstants";

export default function FilterContainer({ sections, activeSection, updateActiveSection }) {
  return (
    <motion.div
      className="filter-container"
      initial={{ position: "relative", top: -40, opacity: 0 }}
      animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1] } }}
    >
      <AnimateSharedLayout>
        {sections.map((section, index) => {
          return (
            <Filter
              key={index}
              text={localize(section.title)}
              isActive={activeSection === section.title}
              onClick={() => updateActiveSection(section.title)}
            />
          );
        })}
        <Filter
          text={localize("Balancing_TaxSummary")}
          isActive={activeSection === SECTION_CONSTANTS.TAX_SUMMARY}
          onClick={() => updateActiveSection(SECTION_CONSTANTS.TAX_SUMMARY)}
        />
        <Filter
          text={localize("Balancing_ShowAll")}
          isActive={activeSection === SECTION_CONSTANTS.SHOW_ALL}
          onClick={() => updateActiveSection(SECTION_CONSTANTS.SHOW_ALL)}
        />
      </AnimateSharedLayout>
    </motion.div>
  );
}
