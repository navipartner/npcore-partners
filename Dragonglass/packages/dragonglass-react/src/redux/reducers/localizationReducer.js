import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import { createReducer } from "dragonglass-redux";
import initialState from "../initialState.js";
import { setLocalization } from "../actions/localizationActions";
import { DRAGONGLASS_LOCALIZE } from "../actions/localizationActionTypes";

export const MISSING_CAPTION = "#NAME?";

const localization = createReducer(initialState.localization, {
  [DRAGONGLASS_LOCALIZE]: (state, payload) => ({
    ...state,
    ...payload,
    _initial: undefined,
  }),
});

export default localization;

function mapStateToProps(state, ownProps) {
  const { localization } = state;
  let { caption } = ownProps;
  if (caption.startsWith("l$.")) {
    caption = caption.substring("3");
  }
  return {
    caption:
      localization[caption] ||
      (localization._initial ? "" : `${MISSING_CAPTION}(${caption})`),
  };
}

function mapFullStateToProps(state) {
  const { localization } = state;
  return { localization };
}

const mapViewsDispatchToProps = (dispatch) =>
  bindActionCreators(
    {
      setLocalization,
    },
    dispatch
  );

export const bindComponentToLocalizationState = (component) =>
  connect(mapStateToProps)(component);

export const bindComponentToLocalizationStateFull = (component) =>
  connect(mapFullStateToProps)(component);

export const bindComponentToLocalizationDispatch = (component) =>
  connect(null, mapViewsDispatchToProps)(component);

export const bindComponentToLocalization = (component) =>
  connect(mapStateToProps, mapViewsDispatchToProps)(component);
