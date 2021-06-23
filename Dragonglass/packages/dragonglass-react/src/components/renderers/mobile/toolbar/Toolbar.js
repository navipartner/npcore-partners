import React from "react";
import { useSelector } from "react-redux";
import { mobileActions } from "../../../../redux/mobile/mobile-actions";
import {
  searchSelector,
  subpage,
  toolbar,
} from "../../../../redux/mobile/mobile-selectors";
import { Hamburger } from "../Hamburger";
import { motion, AnimatePresence } from "framer-motion";
import { ToolbarContent } from "./ToolbarContent";
import Search from "../search/Search";
import SearchHistory from "../search/SearchHistory";

const getIcon = (icon, selected) => `${selected ? "fas" : "fat"} ${icon}`;

const animationDelay = 0.1;
const bezierCurve = [0.34, 1.56, 0.64, 1];

const variants = {
  hidden: (custom) => {
    return {
      left: 100,
      opacity: 0,
      transition: {
        ease: bezierCurve,
        delay: animationDelay * (custom.length - custom.index - 1),
      },
    };
  },
  visible: (custom) => {
    return {
      left: 0,
      opacity: 1,
      transition: {
        ease: bezierCurve,
        delay: animationDelay * (2 + custom.index),
      },
    };
  },
};

const Option = ({ active, option, index, update, length }) => (
  <motion.div
    className={`toolbar__option ${active ? "toolbar__option--active" : ""}`}
    onClick={() => (option.action ? option.action() : update(index))}
    initial="hidden"
    animate="visible"
    variants={variants}
    custom={{ index, length, option }}
    exit="hidden"
  >
    <span className={getIcon(option.icon, active)}></span>
  </motion.div>
);

const getToolbarFromPage = (pages) => {
  const current = useSelector(subpage);
  const selectedPage = pages[current];
  if (!selectedPage) {
    //TODO: This happens before of the early "optimization" which renders all known views and then hides those that are not active
    /*
      However, in case of mobile it causes current subpage (which comes from mobile state) to be read from incorrect state. For example
      after login page has been rendered, and login page contains subpages "login", "info", "settings" (for example) and then after
      successful login the sale page is rendered, and it contains subpages "lock", "sale", "items". If the user then clicks "Items" and
      makes the "items" page the current subpage, this renderer will attempt to read "items" from the already rendered login page, and
      since it does not exist there, it will crash.
      This entire over-optimization should be taken out because it doesn't achieve much. Only the current view should ever be rendered
      rather than all known views. That is, only login view, or sale view, or payment view, but not all known views so far.
      When this is done, this entire block won't be necessary anymore.
    */
    return [];
  }
  const { toolbar } = selectedPage;
  if (!toolbar || !ToolbarContent[toolbar]) {
    return [];
  }
  return ToolbarContent[toolbar];
};

export const Toolbar = ({ pages }) => {
  const { selector, areStatesEqual } = toolbar;
  const { selected } = useSelector(selector, areStatesEqual);

  let options = getToolbarFromPage(pages);
  const searchActive = useSelector(searchSelector);

  if (searchActive) {
    options = [];
  }

  return (
    <div className="toolbar toolbar--visible">
      <div className="toolbar__icons">
        {!searchActive && <Hamburger />}

        <AnimatePresence>
          {searchActive && <Search type={searchActive} />}
          {options.map((option, index) => (
            <Option
              key={option.id}
              active={
                selected
                  ? option.id === selected
                  : !option.action && index === 0
              }
              option={option}
              index={index}
              length={options.length}
              update={() => mobileActions.toolbarSelect(option.id)}
            />
          ))}
        </AnimatePresence>
      </div>
      <AnimatePresence>{searchActive && <SearchHistory />}</AnimatePresence>
    </div>
  );
};
