import { NAVEventFactory } from "dragonglass-nav";
import { mobileActions } from "../../../../redux/mobile/mobile-actions";

let preSearch, search;

const getPreSearchMethod = () =>
  preSearch || (preSearch = NAVEventFactory.method({ name: "PreSearch" }));

const getSearchMethod = () =>
  search || (search = NAVEventFactory.method({ name: "Search" }));

export const searchWhileTyping = async (search, type) => {
  search = search.trim().toLowerCase();
  if (!search) {
    return;
  }
  return await getPreSearchMethod().raise({ search, type });
};

export const executeSearch = async (search, type, lastKey = "") => {
  mobileActions.startSearching();
  search = search.trim().toLowerCase();
  if (!search) {
    return;
  }
  return await getSearchMethod().raise({ search, type, lastKey });
};
