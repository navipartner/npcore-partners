import { createReducer } from "dragonglass-redux";
import {
  DRAGONGLASS_VIEW_DEFINE,
  DRAGONGLASS_VIEW_SET_ACTIVE,
} from "../view/view-actions";
import {
  DRAGONGLASS_MOBILE_NAVIGATE_TO,
  DRAGONGLASS_MOBILE_PRE_SEARCH_RESULTS,
  DRAGONGLASS_MOBILE_SEARCH,
  DRAGONGLASS_MOBILE_SEARCH_RESULTS,
  DRAGONGLASS_MOBILE_SHOW_DRAWER,
  DRAGONGLASS_MOBILE_START_SEARCH,
  DRAGONGLASS_MOBILE_TOOLBAR_SELECT,
} from "./mobile-actions";
import initialState from "./mobile-initial";

export const mobile = createReducer(initialState, {
  [DRAGONGLASS_VIEW_DEFINE]: (state, payload) => {
    if (!payload.navigation || !payload.navigation.length) {
      return state;
    }

    let badges = {};
    let defaultPage = payload.navigation[0];
    for (let button of payload.navigation) {
      if (button.default) {
        defaultPage = button;
      }
      if (button.badge && button.page) {
        badges[button.page] = badges[button.page] || {};
        badges[button.page] = button.badge;
      }
    }

    return {
      ...state,
      viewDefaultPages: {
        ...state.viewDefaultPages,
        [payload.tag]: defaultPage.page || null,
      },
      badges: { ...state.badges, ...badges },
    };
  },

  [DRAGONGLASS_VIEW_SET_ACTIVE]: (state, payload) => {
    const page = state.viewDefaultPages[payload] || null;
    return {
      ...state,
      subpage: page || null,
      defaultPage: page || null,
      search: null,
      relativePageIndex: 0,
    };
  },

  [DRAGONGLASS_MOBILE_NAVIGATE_TO]: (state, payload) => {
    if (state.relativePageIndex === payload.index) {
      return state;
    }

    const newState = {
      search: null,
      relativePageIndex: payload.index,
      toolbar: payload.toolbar || initialState.toolbar,
      subpage: payload.subpage || initialState.subpage,
    };
    return { ...state, ...newState };
  },

  [DRAGONGLASS_MOBILE_TOOLBAR_SELECT]: (state, payload) => {
    if (state.selected === payload) {
      return state;
    }

    const newState = {
      ...state,
      toolbar: { ...state.toolbar, selected: payload },
    };
    return newState;
  },

  [DRAGONGLASS_MOBILE_SHOW_DRAWER]: (state, payload) => {
    if (state.drawer.visible === payload) {
      return state;
    }

    const newState = {
      ...state,
      drawer: { ...state.drawer, visible: payload },
    };
    return newState;
  },

  [DRAGONGLASS_MOBILE_SEARCH]: (state, payload) => {
    if (state.search === payload) {
      return state;
    }

    return {
      ...state,
      search: payload,
      searchResults: initialState.searchResults,
      preSearchResults: initialState.preSearchResults,
    };
  },

  [DRAGONGLASS_MOBILE_PRE_SEARCH_RESULTS]: (state, payload) => {
    return {
      ...state,
      searchResults: initialState.searchResults,
      preSearchResults: payload,
    };
  },

  [DRAGONGLASS_MOBILE_SEARCH_RESULTS]: (state, payload) => {
    const results = payload.results.filter(
      (result) => !state.searchResults.results.find((r) => r.no === result.no)
    );
    return {
      ...state,
      searchResults: {
        results: [...state.searchResults.results, ...results],
        hasMoreResults: payload.hasMore,
        searching: false,
      },
      preSearchResults: initialState.preSearchResults,
    };
  },

  [DRAGONGLASS_MOBILE_START_SEARCH]: (state) => {
    return {
      ...state,
      searchResults: {
        ...state.searchResults,
        searching: true,
      },
    };
  },
});
