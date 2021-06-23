/**
 * Retrieves the index of the currently selected page in mobile navigation bar. The index is relative to the default index.
 * @param {Object} state Current state of the Redux store.
 */
export const relativePageIndex = (state) => state.mobile.relativePageIndex;

/**
 * Retrieves the name of the default page in mobile navigation bar.
 * @param {Object} state
 */
export const defaultPage = (state) => state.mobile.defaultPage;

/**
 * Retrieves a boolean indicating whether the page represented by invoking component is the currently selected page in mobile navigation bar.
 * @param {Object} state Current state of the Redux store.
 * @param {Number} index Index of the page represented by the invoking component. Must be passed, or selector won't work correctly!
 */
export const activePage = (state, index) =>
  state.mobile.relativePageIndex === index;

/**
 * Contains selector and equality function for mobile toolbar state
 */
export const toolbar = {
  /**
   * Retrieves mobile toolbar definition from the Redux store.
   * @param {Object} state Current state of the Redux store.
   */
  selector: (state) => state.mobile.toolbar,

  /**
   * Compares current to previous toolbar definition, avoids shallow (reference) comparison that would always yield true.
   */
  areStatesEqual: (current, prev) => {
    return current.selected === prev.selected;
  },
};

/**
 * Retrieves the currently selected option from the mobile toolbar
 * @param {Object} state Current state of the Redux store.
 */
export const selectedToolbarOption = (state) => state.mobile.toolbar.selected;

/**
 * Retrieves mobile subpage definition from the Redux store.
 * @param {Object} state Current state of the Redux store.
 */
export const subpage = (state) => state.mobile.subpage;

/**
 * Retrieves mobile drawer visible state from the Redux store.
 * @param {Object} state Current state of the Redux store.
 */
export const drawerVisible = (state) => state.mobile.drawer.visible;

/**
 * Retrieves the current state of the search feature (null = not shown; any string = search shown, string contains the name of search facility to use)
 * @param {Object} state Current state of the Redux store.
 */
export const searchSelector = (state) => state.mobile.search;

/**
 * Retrieves pre-search results
 * @param {Object} state Current state of the Redux store.
 */
export const preSearchResultsSelector = (state) =>
  state.mobile.preSearchResults;

/**
 * Retrieves search results
 * @param {Object} state Current state of the Redux store.
 */
export const searchResultsSelector = (state) => state.mobile.searchResults;
