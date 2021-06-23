import { mobileActions } from "../../../../redux/mobile/mobile-actions";
import {
  MOBILE_BUTTON_OTHER,
  MOBILE_BUTTON_VIEW,
  MOBILE_SEARCH_TYPES,
} from "../mobileConstants";

export const ToolbarContent = {
  "menu-buttons": [
    {
      id: MOBILE_BUTTON_VIEW.LIST,
      icon: "fa-list",
    },
    {
      id: MOBILE_BUTTON_VIEW.COLUMNS,
      icon: "fa-line-columns",
    },
    {
      id: MOBILE_BUTTON_VIEW.GRID,
      icon: "fa-grid-2",
    },
    {
      id: MOBILE_BUTTON_VIEW.GRID_SMALL,
      icon: "fa-grid",
    },
  ],
  "search-item": [
    {
      id: MOBILE_BUTTON_OTHER.SEARCH,
      icon: "fa-magnifying-glass",
      action: () => mobileActions.openSearch(MOBILE_SEARCH_TYPES.ITEM),
    },
  ],
};
