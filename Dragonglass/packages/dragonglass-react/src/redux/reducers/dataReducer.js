import { combineReducers } from "redux";
import { createReducer } from "dragonglass-redux";
import {
  DRAGONGLASS_DATA_DEFINE_SOURCE,
  DRAGONGLASS_DATA_UPDATE,
  DRAGONGLASS_DATA_SET_CURRENT,
  DRAGONGLASS_DATA_SET_COPY,
  DRAGONGLASS_DATA_SET_DELETE,
  DRAGONGLASS_DATA_SET_TOGGLESELECTION,
  DRAGONGLASS_DATA_SET_DELETE_LINE,
  DRAGONGLASS_DATA_RESET_SETS,
} from "../actions/dataActionTypes";
import initialState from "../initialState.js";
import {
  setSetCurrentPositionAction,
  toggleSelectionAction,
} from "../actions/dataActions.js";
import { bindToMap, bindToMapExtended } from "../reduxHelper";

/**
 * This function receives the previous state of a data set, and a new state of the same dataset. It returns a new
 * data set object if any changes were applied, otherwise it returns the previous state of the set.
 * @param {Object} set Previous state of the set to update
 * @param {Object} payload New state of the set to update
 */
const applySetUpdate = (set, payload) => {
  let changed = false;
  const setNew = { ...set };
  const updated = {};

  for (let rowUpdated of payload.rows) {
    const rowExisting = (setNew.rows || []).find(
      (row) =>
        row.position === rowUpdated.position ||
        (row.pending && row.position === rowUpdated._pendingPosition)
    );
    if (rowExisting && rowUpdated._pendingPosition) {
      delete rowUpdated._pendingPosition;
      delete rowExisting.pending;
    }

    // 1: row not found
    if (!rowExisting) {
      // 1.a: row is marked as deleted, and isn't known from before - no action needed
      if (rowUpdated.deleted) continue;

      // 1.b: new row just arrived
      changed = true;
      setNew.rows.push(rowUpdated);
      continue;
    }

    // 2. Existing row, but deleted
    if (rowUpdated.deleted) {
      changed = true;
      setNew.rows = setNew.rows.filter(
        (row) => row.position !== rowUpdated.position
      );
      continue;
    }

    // 3. Existing row, updated
    let isRowUpdated = false;
    const { deleted, fields, ...rest } = rowUpdated;
    for (let key of Object.keys(rest)) {
      if (rowExisting[key] !== rowUpdated[key]) {
        changed = true;
        isRowUpdated = true;
        rowExisting[key] = rowUpdated[key];
      }
    }
    for (let fieldUpdated of Object.keys(fields)) {
      if (rowExisting.fields[fieldUpdated] !== fields[fieldUpdated]) {
        changed = true;
        isRowUpdated = true;
        rowExisting.fields[fieldUpdated] = fields[fieldUpdated];
      }
    }
    if (isRowUpdated) updated[rowUpdated.position] = true;
  }

  // Check totals
  if (payload.totals) {
    for (let total of Object.keys(payload.totals)) {
      if (setNew.totals[total] !== payload.totals[total]) {
        changed = true;
        setNew.totals[total] = payload.totals[total];
      }
    }
  }

  // Check current position
  if (
    !payload._stillPending &&
    setNew.currentPosition !== payload.currentPosition
  ) {
    changed = true;
    setNew.currentPosition = payload.currentPosition;
  }

  if (changed) {
    const newRows = [];
    for (let row of setNew.rows)
      newRows.push(updated[row.position] ? { ...row } : row);
    setNew.rows = newRows;
    return setNew;
  }

  return set;
};

const sources = createReducer(initialState.data.sources, {
  [DRAGONGLASS_DATA_DEFINE_SOURCE]: (state, payload) => {
    let newState = { ...state },
      changed = false;
    for (let sourceName of Object.keys(payload)) {
      let source = payload[sourceName];
      let thisState = newState[sourceName];
      if (!thisState || JSON.stringify(thisState) !== JSON.stringify(source)) {
        changed = true;
        newState[sourceName] = source;
      }
    }
    return changed ? newState : state;
  },

  [DRAGONGLASS_DATA_SET_COPY]: (state, payload) => {
    const { sourceName, targetName } = payload;
    const newState = { ...state };
    newState[targetName] = JSON.parse(
      JSON.stringify(state[sourceName] || { columns: [] })
    );
    return newState;
  },

  [DRAGONGLASS_DATA_SET_DELETE]: (state, payload) => {
    if (!state.hasOwnProperty(payload)) return state;

    const newState = { ...state };
    delete newState[payload];
    return newState;
  },
});

const sets = createReducer(initialState.data.sets, {
  [DRAGONGLASS_DATA_UPDATE]: (state, payload) => {
    let newState = { ...state },
      changed = false;

    for (let setName of Object.keys(payload)) {
      let set = payload[setName];
      if (!newState[setName]) {
        changed = true;
        const { currentPosition, rows, totals } = set;
        newState[setName] = { currentPosition, rows, totals };
      } else {
        let updatedSet = applySetUpdate(newState[setName], set);
        if (updatedSet !== newState[setName]) {
          changed = true;
          newState[setName] = updatedSet;
        }
      }
      if (newState[setName].rows.length) {
        let currentRow = newState[setName].rows.find(
          (row) => row.position === newState[setName].currentPosition
        );
        if (currentRow && !currentRow.pending)
          newState[setName].lastValidPosition = currentRow.position;
      } else {
        newState[setName].lastValidPosition = null;
      }
    }

    return changed ? newState : state;
  },

  [DRAGONGLASS_DATA_SET_DELETE_LINE]: (state, payload) => {
    const newState = { ...state };
    const set = (newState[payload.dataSource] = {
      ...newState[payload.dataSource],
    });
    set.rows = set.rows.filter(
      (row) => row.position !== payload.currentPosition
    );
    set.currentPosition = payload._previousPosition;
    if (!set.rows.find((r) => r.position === set.currentPosition)) {
      set.currentPosition = set.lastValidPosition;
      if (!set.rows.find((r) => r.position === set.currentPosition))
        set.currentPosition = null;
    }
    return newState;
  },

  [DRAGONGLASS_DATA_SET_CURRENT]: (state, payload) => {
    const newState = { ...state };
    const { setName, position } = payload;
    if (!newState[setName] || newState[setName].currentPosition !== position) {
      newState[setName] = { ...newState[setName], currentPosition: position };
      return newState;
    }
    return state;
  },

  [DRAGONGLASS_DATA_SET_COPY]: (state, payload) => {
    const { sourceName, targetName } = payload;
    const newState = { ...state };
    newState[targetName] = JSON.parse(
      JSON.stringify(state[sourceName] || { rows: [] })
    );
    if (newState[targetName].rows.length) {
      newState[targetName].currentPosition =
        newState[targetName].rows[0].position;
      newState[targetName]._selections = [];
      newState[targetName].rows.forEach((row) =>
        newState[targetName]._selections.push(row.position)
      );
    }
    return newState;
  },

  [DRAGONGLASS_DATA_SET_DELETE]: (state, payload) => {
    if (!state.hasOwnProperty(payload)) return state;

    const newState = { ...state };
    delete newState[payload];
    return newState;
  },

  [DRAGONGLASS_DATA_SET_TOGGLESELECTION]: (state, payload) => {
    const { source, position } = payload;
    const newState = { ...state };
    const set = newState[source];
    if (!set) return state;

    if (set._selections.includes(position))
      set._selections = set._selections.filter((p) => p !== position);
    else set._selections.push(position);

    return newState;
  },

  [DRAGONGLASS_DATA_RESET_SETS]: (state) => {
    const newState = { ...state };
    Object.keys(newState).forEach((key) => {
      newState[key] = {
        currentPosition: null,
        lastValidPosition: null,
        rows: [],
        totals: {},
      };
    });
    return newState;
  },
});

export default combineReducers({
  sources,
  sets,
});

const emptyDataSource = {
  columns: [],
};
const emptyDataSet = {
  rows: [],
};

const getDataSourceFromState = (props, state) => {
  const name =
    props.dataSourceName || (props.binding && props.binding.dataSource);
  return state.data.sources[name] || emptyDataSource;
};
const dataSourceMap = {
  state: (state, ownProps, extended) => {
    const dataSource = getDataSourceFromState(ownProps, state);
    const result = { dataSource };
    if (extended.includeData) {
      const name =
        ownProps.dataSourceName ||
        (ownProps.binding && ownProps.binding.dataSource);
      Object.assign(result, { data: state.data.sets[name] || emptyDataSet });
    }
    return result;
  },
};

const dataSetMap = {
  state: (state, ownProps) => ({
    dataSource: getDataSourceFromState(ownProps, state),
    data: state.data.sets[ownProps.dataSourceName] || emptyDataSet,
    reverse: (state.options.lineOrderOnScreen || 0) === 1,
  }),
};

const repeaterCurrentRowMap = {
  state: (state, ownProps) => {
    const set = state.data.sets[ownProps.dataSourceName] || {};
    return {
      active: ownProps.showSelectColumn
        ? set._selections.includes(ownProps.position)
        : set.currentPosition === ownProps.position,
    };
  },
  dispatch: (dispatch, ownProps) => ({
    setActive: () =>
      dispatch(
        setSetCurrentPositionAction(ownProps.dataSourceName, ownProps.position)
      ),
    toggleSelection: () =>
      dispatch(
        toggleSelectionAction(ownProps.dataSourceName, ownProps.position)
      ),
  }),
};

const currentRowMap = {
  state: (state, ownProps) => {
    if (!ownProps.dataSourceName) {
      return { bound: false, error: "'dataSourceName' property is missing" };
    }

    const set = state.data.sets[ownProps.dataSourceName] || emptyDataSet;
    const row =
      (set && set.rows.find((row) => row.position === set.currentPosition)) ||
      null;
    const result = { currentRow: row, bound: false, set };
    if (ownProps.caption || ownProps.rowOnly) {
      return { ...result, bound: true };
    }

    const propName = ownProps.total ? "total" : ownProps.field ? "field" : "";
    if (!propName) {
      return { ...result, error: "Must specify either 'total' or 'field'" };
    }

    const collectionName = `${propName}s`;
    const collection = ownProps.total ? set.totals : row ? row.fields : [];
    const boundProp = ownProps[propName];
    if (!collection || !collection.hasOwnProperty(boundProp)) {
      return {
        ...result,
        error: `Bound row does not contains '${collectionName}' or '${collectionName}' does not contain '${boundProp}'`,
      };
    }

    const prop = collection[boundProp];

    return { ...result, caption: prop, bound: true };
  },
};

const autoEnableMap = {
  state: (state, ownProps) => {
    if (
      ownProps.dataSourceName &&
      ownProps.button &&
      ownProps.button.autoEnable
    ) {
      const set = state.data.sets[ownProps.dataSourceName];
      return { enabled: set && set.rows ? !!set.rows.length : false };
    }
    return {};
  },
  enhancer: {
    areStatesEqual: (next, prev) =>
      next.data === prev.data || next.data.sets === prev.data.sets,
  },
};

export const bindComponentToDataSourceState = (component, includeData) =>
  bindToMapExtended(component, dataSourceMap, { includeData: !!includeData });
export const bindComponentToDataSetState = (component) =>
  bindToMap(component, dataSetMap);

/**
 * Binds component to the current row state for repeater purposes. This binding provides a boolean flag
 * indicating whether the current row in a repeater is the currently active row for the bound dataset, and
 * an action to set a row as active.
 * @param {React.Component} component Component to bind
 */
export const bindComponentToDataSetRepeaterCurrentRowState = (component) =>
  bindToMap(component, repeaterCurrentRowMap);
export const bindComponentToDataSetCurrentRowState = (component) =>
  bindToMap(component, currentRowMap);
export const bindComponentToDataSetAutoEnableState = (component) =>
  bindToMap(component, autoEnableMap);
