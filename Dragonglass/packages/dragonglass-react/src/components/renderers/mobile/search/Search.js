import React, { useState } from "react";
import Input from "../../../../components/Input";
import { mobileActions } from "../../../../redux/mobile/mobile-actions";
import { motion } from "framer-motion";
import {
  DefaultSearchController,
  SEARCH_CONTROLLER_STATUS,
  SEARCH_SELECT_FROM_HISTORY,
  SEARCH_STATUS_CHANGE,
  useSearchEventListener,
} from "./SearchController";
import { executeSearch, searchWhileTyping } from "./SearchHelper";
import { useSelector } from "react-redux";
import { searchSelector } from "../../../../redux/mobile/mobile-selectors";

export default function Search() {
  const [value, updateValue] = useState("");
  const [renderGeneration, updateRenderGeneration] = useState(0);
  const searchType = useSelector(searchSelector);

  const searchUpdate = (text) => {
    DefaultSearchController.update(text);
    searchWhileTyping(text, searchType);
  };
  const searchEnter = (text) => {
    DefaultSearchController.enter(text);
    executeSearch(text, searchType);
  };
  const searchFocus = () => DefaultSearchController.focus();

  useSearchEventListener(SEARCH_SELECT_FROM_HISTORY, updateValue);
  useSearchEventListener(SEARCH_STATUS_CHANGE, (status) => {
    if (status === SEARCH_CONTROLLER_STATUS.IDLE) {
      updateRenderGeneration(renderGeneration + 1);
    }
  });

  const variants = {
    hidden: {
      left: "-100%",
      opacity: 0,
      width: "20%",
    },
    visible: {
      left: 0,
      opacity: 1,
      width: "100%",
      transition: {
        ease: [0.34, 1.3, 0.64, 1],
        delay: 0.2,
      },
    },
  };

  return (
    <motion.div
      className="search"
      variants={variants}
      initial="hidden"
      animate="visible"
      exit="hidden"
    >
      <div className="search__back" onClick={() => mobileActions.closeSearch()}>
        <i className="fa-thin fa-arrow-left"></i>
      </div>
      <Input
        key={value} // this is unfortunately necessary, because of how the Input control works (TODO: maybe we need a better Input control?)
        editable={true}
        clearOnEnter={true}
        blurOnEnter={true}
        onChange={(text) => searchUpdate(text)}
        onEnter={(text) => searchEnter(text)}
        onFocus={() => searchFocus()}
        erase={true}
        value={value}
        autoFocus={
          DefaultSearchController.status === SEARCH_CONTROLLER_STATUS.IDLE
        }
      />
    </motion.div>
  );
}
