import React, { useState } from "react";
import { motion } from "framer-motion";
import {
  DefaultSearchController,
  SEARCH_CONTROLLER_STATUS,
  SEARCH_STATUS_CHANGE,
  useSearchEventListener,
} from "./SearchController";
import { useSelector } from "react-redux";
import {
  preSearchResultsSelector,
  searchSelector,
} from "../../../../redux/mobile/mobile-selectors";

const getStorageKey = (type) => `SEARCH_HISTORY_${type}`;

const updateHistory = (type, newItem) => {
  let history = getHistory(type);
  newItem = history.find((item) => item.caption === newItem) || {
    count: 0,
    caption: newItem,
  };
  newItem.count++;

  history = history.sort((left, right) => right.count - left.count);
  history = [
    newItem,
    ...history.filter((item) => item.caption !== newItem.caption),
  ];

  localStorage.setItem(getStorageKey(type), JSON.stringify(history));
  return history;
};

const getHistory = (type) => {
  const history = JSON.parse(localStorage.getItem(getStorageKey(type)) || "[]");
  return history;
};

const animationDelay = 0.1;
const bezierCurve = [0.34, 1.56, 0.64, 1];

const variants = {
  hidden: (custom) => {
    return {
      left: -30,
      opacity: 0,
      transition: {
        ease: bezierCurve,
        delay: animationDelay * custom,
      },
    };
  },
  visible: (custom) => {
    return {
      left: 0,
      opacity: 1,
      transition: {
        ease: bezierCurve,
        delay: animationDelay * custom,
      },
    };
  },
};

const ICON_HISTORY = "fa-thin fa-clock";
const ICON_FOUND = "fa-thin fa-magnifying-glass";

const prepareItem = (item, icon) => ({ icon: icon, caption: item.caption });

const transformPreSearchResults = (results) => {
  const keys = Object.keys(results).sort(
    (left, right) => results[right] - results[left]
  );
  return keys.slice(0, 5);
};

const transformToMatchSearch = (search, caption) => (
  <span>
    <strong>{search.toLowerCase()}</strong>
    {caption.substring(search.length)}
  </span>
);

export default function SearchHistory() {
  const searchActive = useSelector(searchSelector);
  const preSearchResults = useSelector(preSearchResultsSelector);
  const [items, updateItems] = useState(
    getHistory(searchActive)
      .slice(0, 4)
      .map((item) => prepareItem(item, ICON_HISTORY))
  );
  const [entering, updateEntering] = useState(false);

  useSearchEventListener(SEARCH_STATUS_CHANGE, (status) => {
    switch (status) {
      case SEARCH_CONTROLLER_STATUS.SEARCHING:
        const text = DefaultSearchController.searchTerm;
        const newItems = updateHistory(searchActive, text)
          .slice(0, 4)
          .map((item) => prepareItem(item, ICON_HISTORY));
        updateItems(newItems);
        return;

      case SEARCH_CONTROLLER_STATUS.ENTERING:
        if (entering) {
          return;
        }
        updateEntering(true);
        return;

      case SEARCH_CONTROLLER_STATUS.IDLE:
        if (!entering) {
          return;
        }
        updateEntering(false);
        return;
    }
  });

  return (
    <motion.div
      initial={{ height: 0 }}
      animate={{ height: "auto" }}
      className="history"
      exit={{
        height: 0,
        transition: {
          delay: 0.35,
          ease: [0.34, 1, 0.64, 1],
        },
      }}
    >
      {entering
        ? DefaultSearchController.status === SEARCH_CONTROLLER_STATUS.ENTERING
          ? transformPreSearchResults(preSearchResults).map((item) => {
              return (
                <motion.div
                  className="history__item"
                  key={item}
                  initial="hidden"
                  animate="visible"
                  variants={variants}
                  custom={item}
                  exit="hidden"
                  onClick={() =>
                    DefaultSearchController.selectFromHistory(item)
                  }
                >
                  <i className={ICON_FOUND}></i>
                  <div className="history__caption">
                    {transformToMatchSearch(
                      DefaultSearchController.preSearchTerm,
                      item
                    )}
                  </div>
                </motion.div>
              );
            })
          : null
        : items.map((item) => {
            return (
              <motion.div
                className="history__item"
                key={item.caption}
                initial="hidden"
                animate="visible"
                variants={variants}
                custom={item.caption}
                exit="hidden"
                onClick={() =>
                  DefaultSearchController.selectFromHistory(item.caption)
                }
              >
                <i className={item.icon}></i>
                <div className="history__caption">{item.caption}</div>
              </motion.div>
            );
          })}
    </motion.div>
  );
}
