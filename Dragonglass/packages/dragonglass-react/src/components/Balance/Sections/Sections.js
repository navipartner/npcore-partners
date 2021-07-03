import React from "react";
import { useSelector } from "react-redux";
import { balancingSelectStatistics } from "../../../redux/balancing/balancing-selectors";
import { motion } from "framer-motion";
import Section from "./Section";
import BalancingSection from "./BalancingSection";
import TaxSummary from "./TaxSummary";
import Title from "./Title";
import { SECTION_CONSTANTS } from "./SectionConstants";

export default function Sections({ layout, activeSection }) {
  const displaySingleSection =
    activeSection !== SECTION_CONSTANTS.SHOW_ALL && activeSection !== SECTION_CONSTANTS.TAX_SUMMARY;
  const centerSections = activeSection !== SECTION_CONSTANTS.SHOW_ALL;
  const state = useSelector(balancingSelectStatistics);
  const sections = layout.sections.filter((section) => section.title !== SECTION_CONSTANTS.BALANCING);
  const selectedSection = displaySingleSection && sections.find((section) => section.title === activeSection);
  const flexDirectionColumn = activeSection === SECTION_CONSTANTS.SHOW_ALL ? "sections--column" : "";

  return (
    <motion.div className={`sections ${centerSections ? "sections--centered" : ""} ${flexDirectionColumn}`}>
      {activeSection !== SECTION_CONSTANTS.SHOW_ALL && <Title activeSection={activeSection} />}
      <BalancingSection
        layout={layout.sections.filter((section) => section.title === SECTION_CONSTANTS.BALANCING)[0]}
        isSingle={centerSections}
        activeSection={activeSection}
      />
      {activeSection === SECTION_CONSTANTS.SHOW_ALL && (
        <>
          <TaxSummary layout={layout.taxSummary} isSingleSection={false} data={state.taxSummary} />
          {sections.map((sectionLayout, index) => {
            return (
              <Section
                key={index}
                layout={sectionLayout}
                isSingle={false}
                data={state[sectionLayout.select]}
                index={index}
              />
            );
          })}
        </>
      )}
      {activeSection === SECTION_CONSTANTS.TAX_SUMMARY && (
        <TaxSummary layout={layout.taxSummary} isSingle={true} data={state.taxSummary} />
      )}
      {displaySingleSection && (
        <Section layout={selectedSection} isSingle={true} data={state[selectedSection.select]} />
      )}
    </motion.div>
  );
}
