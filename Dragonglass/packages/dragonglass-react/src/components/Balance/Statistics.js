import React, { useState } from "react";
import FilterContainer from "./FilterContainer";
import StatisticsButtons from "./StatisticsButtons";
import Sections from "./Sections/Sections";
import { SECTION_CONSTANTS } from "./Sections/SectionConstants";

export default function Statistics({ layout, onCashCountClick }) {
  const [activeSection, setActiveSection] = useState(
    layout.sections.filter((section) => section.title !== SECTION_CONSTANTS.BALANCING)[0].title
  );

  const updateActiveSection = (section) => {
    setActiveSection(section);
  };

  const sections = layout.sections.filter((section) => section.title !== SECTION_CONSTANTS.BALANCING);

  return (
    <div className="statistics">
      <div className="heading">Statistics / Workshift Details - 33</div>
      <FilterContainer sections={sections} activeSection={activeSection} updateActiveSection={updateActiveSection} />
      <Sections layout={layout} activeSection={activeSection} />
      <StatisticsButtons onCashCountClick={onCashCountClick} />
    </div>
  );
}
