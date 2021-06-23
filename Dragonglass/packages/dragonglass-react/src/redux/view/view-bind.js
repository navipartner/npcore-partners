import { bindToMap } from "../reduxHelper";
import { setActiveViewAction } from "./view-actions";

const layoutMap = {
  state: (state, ownProps) => {
    const { layouts } = state.view.views,
      { tag } = ownProps;
    return { layout: layouts.hasOwnProperty(tag) ? layouts[tag] : {} };
  },
  enhancer: {
    areStatesEqual: (next, prev) => {
      if (next.view.views.layouts !== prev.view.views.layouts) return false;

      if (
        Object.keys(next.view.views.layouts).length !==
        Object.keys(prev.view.views.layouts).length
      )
        return false;

      for (let key in next.view.views.layouts) {
        if (next.view.views.layouts.hasOwnProperty(key))
          if (next.view.views.layouts[key] !== prev.view.views.layouts[key])
            return false;
      }

      return true;
    },
  },
};

const activeMap = {
  state: (state, ownProps) => {
    const { view } = state;
    return { active: view.active === ownProps.tag };
  },
  enhancer: {
    areStatesEqual: (next, prev) => {
      const nextActive = next.view.active;
      const prevActive = prev.view.active;

      // If either view is unknown, we must refresh!
      if (!nextActive || !prevActive) {
        return false;
      }

      // If active tag changed, we must refresh!
      if (nextActive !== prevActive) {
        return false;
      }

      // If active tag did not change, but layout changed, we must refresh!
      const nextLayout = next.view.views.layouts[nextActive];
      const prevLayout = prev.view.views.layouts[prevActive];
      return nextLayout === prevLayout;
    },
  },
};

const tagMap = {
  state: (state) => ({ tags: state.view.views.tags }),
  enhancer: {
    areStatesEqual: (next, prev) =>
      next.view.views.tags === prev.view.views.tags,
  },
};

const viewMap = {
  state: (state) => ({
    view: state.view,
  }),
  enhancer: {
    areStatesEqual: (next, prev) =>
      next.view.active === prev.view.active &&
      next.view.views.tags === prev.view.views.tags,
  },
  dispatch: (dispatch) => ({
    setActiveView: (tag) => dispatch(setActiveViewAction(tag)),
  }),
};

export const bindComponentToViewLayoutState = (component) =>
  bindToMap(component, layoutMap);
export const bindComponentToViewActiveState = (component) =>
  bindToMap(component, activeMap);
export const bindComponentToViewTagsState = (component) =>
  bindToMap(component, tagMap);
export const bindComponentToViewState = (component) =>
  bindToMap(component, viewMap);
