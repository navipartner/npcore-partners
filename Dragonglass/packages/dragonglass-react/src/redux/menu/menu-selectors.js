import { bindToMap } from "../reduxHelper";
import {
  getButtonGridMenu,
  MenuButtonInfo,
} from "../../classes/ButtonGridMenuBuilder.js";
import { useSelector } from "react-redux";

const getMenuObject = (menu, id, flat, layout, state) => {
  if (!id || !menu[id]) {
    return {};
  }

  return {
    menu: flat
      ? menu[id].MenuButtons.map(
          (button) => new MenuButtonInfo(button, null, 0, 0)
        ).sort(
          (left, right) =>
            (left.Row || 1000) * 1000 +
            left.Column -
            ((right.Row || 1000) * 1000 + right.Column)
        )
      : getButtonGridMenu(
          menu[id] || { MenuButtons: [], generation: 0 },
          layout.rows,
          layout.columns,
          state.transactionState
        ),
  };
};

const menuStateMap = {
  state: (state, ownProps) => {
    const { menu } = state;
    const layout = ownProps.layout || {};
    const id = (layout && layout.source) || "";
    const flat = ownProps.flat;

    return getMenuObject(menu, id, flat, layout, state);
  },
  enhancer: {
    areStatesEqual: (next, prev) =>
      next.menu._generation === prev.menu._generation,
  },
};

export const bindComponentToMenuState = (component) =>
  bindToMap(component, menuStateMap);

export const useMenu = (id) => {
  const menu = useSelector(
    (state) => state.menu,
    (left, right) =>
      left.menu === right.menu && left.menu.generation === right.menu.generation
  );

  const menuObject = getMenuObject(menu, id, true);
  return menuObject.menu || [];
};
