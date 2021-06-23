import React, { useState } from "react";
import { useSelector } from "react-redux";
import {
  balancingSelectConfirmed,
  balancingSelectStatistics,
  balancingState,
} from "../../redux/balancing/balancing-selectors";
import Caption from "../Caption";
import { localize } from "../LocalizationManager";
import { motion, AnimateSharedLayout } from "framer-motion";
import { setBalancingState } from "./BackEndActions";
import { StateStore } from "../../redux/StateStore";
import { Popup } from "../../dragonglass-popup/PopupHost";

const SHOW_ALL = "l$.Balancing_ShowAll";
const TAX_SUMMARY = "l$.Balancing_TaxSummary";
const BALANCING = "l$.Balancing_Balancing";

const Section = ({ layout, isSingle, data, index }) => {
  const delay = index ? 0.1 * (index + 1) : 0.15;

  return (
    <motion.div
      className={`section ${isSingle ? "section--single" : ""}`}
      initial={{ position: "relative", top: -40, opacity: 0 }}
      animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: delay } }}
      key={layout.title}
    >
      {!isSingle && (
        <h1>
          <Caption caption={layout.title} />
        </h1>
      )}
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
};

const BalancingSection = ({ layout, isSingle, data, activeSection }) => {
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
};

const Subsection = ({ layout, isSingle, data }) => {
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
};

const TaxSummary = ({ layout, isSingle, data }) => {
  return (
    <motion.div
      className={`section ${isSingle ? "section--single" : ""}`}
      initial={{ position: "relative", top: -40, opacity: 0 }}
      animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: isSingle ? 0.15 : 0.5 } }}
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
};

const Buttons = ({ onCashCountClick }) => {
  const confirmed = useSelector(balancingSelectConfirmed);

  const close = async (closeClicked) => {
    let completeClose = true;
    if (!confirmed) {
      completeClose = await Popup.confirm(localize("Balancing_NotCompletedConfirmation"));
    }
    if (!completeClose) {
      return;
    }
    setBalancingState(balancingState(StateStore.getState()), !!closeClicked);
  };

  return (
    <div className="buttons">
      <div className="buttons__container">
        <div className="button">
          <i className="fa-light fa-print"></i> {localize("Balancing_ButtonPrintStatistics")}
        </div>
        <div
          className={`button ${confirmed ? "button--confirmed" : "button--not-confirmed"}`}
          onClick={onCashCountClick}
        >
          {confirmed ? (
            <>
              <i className="fa-light fa-circle-check"></i> {localize("Balancing_ButtonCashCount")}
            </>
          ) : (
            <>
              <i className="fa-light fa-circle-exclamation"></i>{" "}
              <span>
                {localize("Balancing_ButtonCashCount")} {localize("Balancing_ButtonCashCountNotCompleted")}
              </span>
            </>
          )}
        </div>
      </div>
      <div className="buttons__container">
        <div className="button" onClick={() => close(true)}>
          {localize("Balancing_ButtonComplete")}
        </div>
        <div className="button" onClick={() => close(false)}>
          {localize("Global_Cancel")}
        </div>
      </div>
    </div>
  );
};

const FilterContainer = ({ layoutSections, activeSection, updateActiveSection }) => {
  const sections = layoutSections.filter((section) => section.title !== BALANCING);

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
          isActive={activeSection === TAX_SUMMARY}
          onClick={() => updateActiveSection(TAX_SUMMARY)}
        />
        <Filter
          text={localize("Balancing_ShowAll")}
          isActive={activeSection === SHOW_ALL}
          onClick={() => updateActiveSection(SHOW_ALL)}
        />
      </AnimateSharedLayout>
    </motion.div>
  );
};

const Filter = ({ text, isActive, onClick }) => {
  return (
    <motion.div className={`filter ${isActive ? "filter--active" : ""}`} onClick={onClick}>
      {text}
      {isActive && (
        <motion.div
          className="filter__active-background"
          layoutId="active-filter-background"
          transition={{
            duration: 0.2,
          }}
        />
      )}
    </motion.div>
  );
};

const Sections = ({ layout, activeSection }) => {
  const displaySingleSection = activeSection !== SHOW_ALL && activeSection !== TAX_SUMMARY;
  const centerSections = activeSection !== SHOW_ALL;
  const state = useSelector(balancingSelectStatistics);
  const sections = layout.sections.filter((section) => section.title !== BALANCING);
  const selectedSection = displaySingleSection && sections.find((section) => section.title === activeSection);

  return (
    <motion.div className={`sections ${centerSections ? "sections--centered" : ""}`}>
      <Title activeSection={activeSection} />
      <BalancingSection
        layout={layout.sections.filter((section) => section.title === BALANCING)[0]}
        isSingle={centerSections}
        activeSection={activeSection}
      />
      {activeSection === SHOW_ALL && (
        <>
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
          <TaxSummary layout={layout.taxSummary} isSingleSection={false} data={state.taxSummary} />
        </>
      )}
      {activeSection === TAX_SUMMARY && (
        <TaxSummary layout={layout.taxSummary} isSingle={true} data={state.taxSummary} />
      )}
      {displaySingleSection && (
        <Section layout={selectedSection} isSingle={true} data={state[selectedSection.select]} />
      )}
    </motion.div>
  );
};

const Title = ({ activeSection }) => {
  if (activeSection !== SHOW_ALL) {
    return (
      <motion.h1
        className="section-title"
        initial={{ position: "relative", top: -40, opacity: 0 }}
        animate={{ top: 0, opacity: 1, transition: { ease: [0.34, 1.56, 0.64, 1], delay: 0 } }}
        key={activeSection}
      >
        {localize(activeSection)}
      </motion.h1>
    );
  }

  return null;
};

export default function Statistics({ layout, onCashCountClick }) {
  const [activeSection, setActiveSection] = useState(
    layout.sections.filter((section) => section.title !== BALANCING)[0].title
  );

  const updateActiveSection = (section) => {
    setActiveSection(section);
  };

  return (
    <div className="statistics">
      <div className="heading">Statistics / Workshift Details - 33</div>
      <FilterContainer
        layoutSections={layout.sections}
        activeSection={activeSection}
        updateActiveSection={updateActiveSection}
      />
      <Sections layout={layout} activeSection={activeSection} />
      <Buttons onCashCountClick={onCashCountClick} />
    </div>
  );
}
