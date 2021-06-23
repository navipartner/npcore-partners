import { EventDispatcher } from "dragonglass-core";
import { useEffect } from "react";

export const SEARCH_ENTER = "SEARCH_ENTER";
export const SEARCH_UPDATE = "SEARCH_UPDATE";
export const SEARCH_RESET = "SEARCH_RESET";
export const SEARCH_SELECT_FROM_HISTORY = "SEARCH_SELECT_FROM_HISTORY";
export const SEARCH_STATUS_CHANGE = "SEARCH_STATUS_CHANGE";

export const SEARCH_CONTROLLER_STATUS = {
  IDLE: "STATUS_IDLE",
  ENTERING: "STATUS_ENTERING",
  SEARCHING: "STATUS_SEARCHING",
};

export const useSearchEventListener = (event, listener) =>
  useEffect(() => {
    DefaultSearchController.dispatcher.addEventListener(event, listener);
    return () =>
      DefaultSearchController.dispatcher.removeEventListener(event, listener);
  });

export class SearchController {
  constructor() {
    this.dispatcher = new EventDispatcher([
      SEARCH_ENTER,
      SEARCH_UPDATE,
      SEARCH_RESET,
      SEARCH_SELECT_FROM_HISTORY,
      SEARCH_STATUS_CHANGE,
    ]);
    this._status = SEARCH_CONTROLLER_STATUS.IDLE;
    this._searchTerm = "";
    this._preSearchTerm = "";
  }

  get searchTerm() {
    return this._searchTerm;
  }

  set searchTerm(value) {
    if (this._searchTerm === value.trim()) {
      return;
    }

    this._searchTerm = value;
    this.status = SEARCH_CONTROLLER_STATUS.SEARCHING;
  }

  get preSearchTerm() {
    return this._preSearchTerm;
  }

  get status() {
    return this._status;
  }

  set status(value) {
    if (value === this._status) {
      return;
    }
    this._status = value;
    if (this._status === SEARCH_CONTROLLER_STATUS.IDLE) {
      this._searchTerm = "";
    }
    this.dispatcher.raise(SEARCH_STATUS_CHANGE, value);
  }

  selectFromHistory(text) {
    this.dispatcher.raise(SEARCH_SELECT_FROM_HISTORY, text);
  }

  enter(text) {
    this.searchTerm = text;
    this.dispatcher.raise(SEARCH_ENTER, text);
  }

  update(text) {
    if (!text.trim() && this._status === SEARCH_CONTROLLER_STATUS.SEARCHING) {
      return;
    }

    this._preSearchTerm = text;

    this.status = text.trim()
      ? SEARCH_CONTROLLER_STATUS.ENTERING
      : SEARCH_CONTROLLER_STATUS.IDLE;
    this.dispatcher.raise(SEARCH_UPDATE, text);
  }

  focus() {
    if (this._status === SEARCH_CONTROLLER_STATUS.SEARCHING) {
      this.status = SEARCH_CONTROLLER_STATUS.IDLE;
    }
  }

  reset() {
    this.dispatcher.raise(SEARCH_RESET);
  }
}

export const DefaultSearchController = new SearchController();
