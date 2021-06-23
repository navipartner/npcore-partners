import { StateStore } from "../StateStore";

/** Navigates to a page in the mobile navigation bare */
export const DRAGONGLASS_MOBILE_NAVIGATE_TO = "DRAGONGLASS_MOBILE_NAVIGATE_TO";

/** Selects an option in the mobile toolbar */
export const DRAGONGLASS_MOBILE_TOOLBAR_SELECT =
  "DRAGONGLASS_MOBILE_TOOLBAR_SELECT";

/** Shows or hides the "drawer" menu */
export const DRAGONGLASS_MOBILE_SHOW_DRAWER = "DRAGONGLASS_MOBILE_SHOW_DRAWER";

/** Starts or ends the mobile search feature */
export const DRAGONGLASS_MOBILE_SEARCH = "DRAGONGLASS_MOBILE_SEARCH";

// TODO: The following actions should be top-level actions in a top-level reducer because they relevant beyond mobile

/** Updates the pre-search results for mobile search */
export const DRAGONGLASS_MOBILE_PRE_SEARCH_RESULTS =
  "DRAGONGLASS_MOBILE_PRE_SEARCH_RESULTS";

/** Updates the pre-search results for mobile search */
export const DRAGONGLASS_MOBILE_SEARCH_RESULTS =
  "DRAGONGLASS_MOBILE_SEARCH_RESULTS";

/** Updates the pre-search results for mobile search */
export const DRAGONGLASS_MOBILE_START_SEARCH =
  "DRAGONGLASS_MOBILE_START_SEARCH";

export const navigateTo = (payload) => ({
  type: DRAGONGLASS_MOBILE_NAVIGATE_TO,
  payload,
});

export const toolbarSelect = (payload) => ({
  type: DRAGONGLASS_MOBILE_TOOLBAR_SELECT,
  payload,
});

export const showDrawer = (payload) => ({
  type: DRAGONGLASS_MOBILE_SHOW_DRAWER,
  payload,
});

export const search = (payload) => ({
  type: DRAGONGLASS_MOBILE_SEARCH,
  payload,
});

export const preSearchResults = (payload) => ({
  type: DRAGONGLASS_MOBILE_PRE_SEARCH_RESULTS,
  payload,
});

export const searchResults = (payload) => ({
  type: DRAGONGLASS_MOBILE_SEARCH_RESULTS,
  payload,
});

export const startSearch = () => ({
  type: DRAGONGLASS_MOBILE_START_SEARCH,
});

/** Defines mobile redux actions that can be invoked directly from function components (outside connected components) */
export const mobileActions = {
  /**
   * Navigates to a page in the mobile navigation bar
   * @param {Any} payload Payload to send to the action
   */
  navigateTo: (payload) => StateStore.dispatch(navigateTo(payload)),

  /**
   * Selets a toolbar button in the mobile toolbar
   * @param {String} payload Toolbar button identifier
   */
  toolbarSelect: (payload) => StateStore.dispatch(toolbarSelect(payload)),

  /**
   * Shows or hides the drawer menu.
   * @param {Boolean} payload New visible state of the drawer menu.
   */
  showDrawer: (payload) => StateStore.dispatch(showDrawer(payload)),

  /**
   * Starts the search feature.
   */
  openSearch: (type) => StateStore.dispatch(search(type)),

  /**
   * Starts the search feature.
   */
  closeSearch: () => StateStore.dispatch(search(null)),

  /**
   * Indicates that the search request has been sent to the back end.
   */
  startSearching: () => StateStore.dispatch(startSearch()),
};
