import view from "./view/view-reducer";
import localization from "./reducers/localizationReducer";
import menu from "./menu/menu-reducer";
import images from "./reducers/imagesReducer";
import data from "./reducers/dataReducer";
import popups from "./reducers/popupReducer";
import transactionState from "./reducers/transactionStateReducer";
import format from "./reducers/formatReducer";
import options from "./reducers/optionsReducer";
import themes from "./reducers/themesReducer";
import textEnter from "./reducers/textEnterReducer";
import notifications from "./reducers/notificationsReducer";
import fonts from "./reducers/fontReducer";
import errors from "./reducers/errorReducer";
import cart from "./reducers/cartReducer";
import restaurant from "./reducers/restaurantReducer";
import { mobile } from "./mobile/mobile-reducer";
import { balancing } from "./balancing/balancing-reducer";
import lookup from "./lookup/lookup-reducer";

export const rootReducer = {
  view,
  localization,
  menu,
  images,
  data,
  popups,
  transactionState,
  format,
  options,
  themes,
  textEnter,
  notifications,
  fonts,
  errors,
  cart,
  restaurant,
  mobile,
  balancing,
  lookup,
};
