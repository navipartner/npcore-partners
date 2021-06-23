import React, { useState } from "react";
import { useSelector } from "react-redux";
import VisibilitySensor from "react-visibility-sensor";
import {
  searchResultsSelector,
  searchSelector,
} from "../../../../redux/mobile/mobile-selectors";
import {
  DefaultSearchController,
  SEARCH_CONTROLLER_STATUS,
  SEARCH_STATUS_CHANGE,
  useSearchEventListener,
} from "./SearchController";
import { executeSearch } from "./SearchHelper";
import Lottie from "lottie-react";
import searchingAnimation from "../../../../lottie/searching.json";
import notFoundAnimation from "../../../../lottie/notFound.json";
import { KnownWorkflows } from "dragonglass-workflows";
import { createRipple } from "../createRipple";
import { motion, AnimatePresence } from "framer-motion";

const WrapInSensor = ({ children, loadMore }) => {
  return loadMore ? (
    <VisibilitySensor onChange={(visible) => visible && loadMore()}>
      {children}
    </VisibilitySensor>
  ) : (
    children
  );
};

const Result = ({ item, loadMore }) => {
  const descriptionParagraphs = item.description
    ? item.description.split(/\r\n|\n|\r/)
    : [];

  const click = (event, itemNumber) => {
    createRipple(event);
    KnownWorkflows.item({ Code: itemNumber });
  };

  return (
    <WrapInSensor loadMore={loadMore}>
      <div className="result" onClick={(event) => click(event, item.no)}>
        <div className="result__heading">
          <div className="icon">
            <i className="fad fa-image fa-5x"></i>
          </div>
          <div className="item-data">
            <div className="number">Item No. {item.no}</div>
            <div className="name">{item.name}</div>
            <div className="price">Price: {item.price}</div>
          </div>
        </div>
        <div className="result__description">
          {descriptionParagraphs.map((paragraph, index) => {
            return <p key={index}>{paragraph}</p>;
          })}
        </div>
      </div>
    </WrapInSensor>
  );
};

const LoadingMore = () => (
  <motion.div
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    exit={{ opacity: 0 }}
    className="search-results__loadingMore"
  >
    <Lottie animationData={searchingAnimation} />
  </motion.div>
);

const NothingFound = ({ searchType }) => (
  <motion.div
    initial={{ opacity: 0 }}
    animate={{ opacity: 1, transition: { delay: 0.2 } }}
    className="search-results__not-found"
    onClick={() => {
      DefaultSearchController.focus();
    }}
  >
    <motion.div
      initial={{ top: "-30%" }}
      animate={{
        top: 0,
        transition: { delay: 0.2, duration: 0.4, ease: "linear" },
      }}
      className="animation-container"
    >
      <Lottie className="animation" animationData={notFoundAnimation} />
    </motion.div>
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 0.7 }}
      className="text"
    >
      We could not find anything...
    </motion.div>
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="search-again"
    >
      <i className="fat fa-magnifying-glass search-again__icon"></i> Search
      again
    </motion.div>
  </motion.div>
);

const SearchCaption = ({ searchTerm }) => (
  <div className="search-results__caption">Searching for: {searchTerm}</div>
);

export const SearchResults = () => {
  const [searchActive, updateSearchActive] = useState(false);
  const { results, searching, hasMoreResults } = useSelector(
    searchResultsSelector
  );
  const searchType = useSelector(searchSelector);
  const { searchTerm } = DefaultSearchController;

  useSearchEventListener(SEARCH_STATUS_CHANGE, (status) => {
    const newSearching = status === SEARCH_CONTROLLER_STATUS.SEARCHING;
    if (newSearching !== searchActive) {
      updateSearchActive(newSearching);
    }
  });

  if (!searchActive) {
    return null;
  }

  return (
    <div className="search-results">
      <SearchCaption searchTerm={searchTerm} />

      {results.map((item, index) => (
        <Result
          item={item}
          key={item.no}
          loadMore={
            searching || index < results.length - 2 || !hasMoreResults
              ? null
              : () =>
                  executeSearch(
                    searchTerm,
                    searchType,
                    results[results.length - 1].no
                  )
          }
        />
      ))}
      <AnimatePresence>{searching && <LoadingMore />}</AnimatePresence>
      <AnimatePresence>
        {!searching && results.length === 0 && !hasMoreResults && (
          <NothingFound searchType={searchType} />
        )}
      </AnimatePresence>
    </div>
  );
};
