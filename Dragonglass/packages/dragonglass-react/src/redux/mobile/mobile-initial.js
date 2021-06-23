export default {
  relativePageIndex: 0,
  toolbar: {
    options: [],
    selected: null,
  },
  defaultPage: null,
  subpage: null, // TODO: this is actually "page", not "subpage" - should be renamed!
  drawer: {
    visible: false,
  },
  badges: {},
  search: null,
  viewDefaultPages: {},
  preSearchResults: {},
  searchResults: {
    results: [],
    searching: false,
    hasMoreResults: false,
  },
};
