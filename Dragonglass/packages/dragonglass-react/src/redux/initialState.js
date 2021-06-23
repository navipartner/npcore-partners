export default {
  // localizationReducer.js
  localization: {
    _initial: true,
    Actions: {},
  },

  // imagesReducer.js
  images: {},

  // dataReducer.js
  data: {
    sources: {},
    sets: {},
  },

  // popupReducer.js
  popups: [],

  // transactionStateReducer.js
  transactionState: {},

  // formatReducer.js
  format: {
    date: {},
    generation: 0,
  },

  // optionsReducer.js
  options: {
    methodWorkflows: {}, // TODO: Check about this one, what is it? Where is it used?
  },

  // themesReducer.js
  themes: {
    styles: [],
    scripts: [],
    background: {},
    logo: null,
  },

  // textEnterReducer.js
  textEnter: {},

  // notificationsReducer.js
  notifications: {
    panelVisible: false,
    entries: [],
  },

  // fontReducer.js
  fonts: [],

  // errorReducer.js
  errors: [],

  // cartReducer.js
  cart: {
    visible: false,
  },

  // restaurantReducer.js
  restaurant: {
    // Configuration / data
    restaurants: [],
    locations: [],
    waiterPads: [],
    statusesTable: [],
    statusesWaiterPad: [],

    // Active indicators
    activeRestaurant: null,
    activeLocation: null,
    activeTable: null,
    activeWaiterPad: null,

    // Actual statuses
    tableStatus: {},
    waiterPadStatus: {},
    numberOfGuests: {},

    // Other, helper, etc.
    lastLocation: {},
    lastTableWaiterPad: {},
  },
};
