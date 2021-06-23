import {
    DRAGONGLASS_DATA_SET_CURRENT,
    DRAGONGLASS_DATA_UPDATE,
    DRAGONGLASS_DATA_DEFINE_SOURCE,
    DRAGONGLASS_DATA_SET_COPY,
    DRAGONGLASS_DATA_SET_DELETE,
    DRAGONGLASS_DATA_SET_TOGGLESELECTION,
    DRAGONGLASS_DATA_SET_DELETE_LINE,
    DRAGONGLASS_DATA_RESET_SETS
} from "./dataActionTypes";

/**
 * Returns an action that sets the current position in the indicated data set.
 * @param {String} setName Name of the data set to update
 * @param {String} position Position property of the row which should become the current row
 */
export const setSetCurrentPositionAction = (setName, position) => {
    return {
        type: DRAGONGLASS_DATA_SET_CURRENT,
        payload: { setName, position }
    };
};

/**
 * Returns a thunk action that updates data from the JSON object containing data delta.
 * @param {Object} data Data in a JSON object
 */
export const updateDataAction = data =>
    dispatch => {
        var p = dispatch({
            type: DRAGONGLASS_DATA_UPDATE,
            payload: data
        });
        return p;
    };

export const deleteLineAction = line => {
    return {
        type: DRAGONGLASS_DATA_SET_DELETE_LINE,
        payload: line
    };
};

/**
 * Returns an action that defines a data source.
 * @param {Object} source Data source definition in a JOSN object
 */
export const defineDataSourceAction = source => {
    return {
        type: DRAGONGLASS_DATA_DEFINE_SOURCE,
        payload: source
    };
};

/**
 * Returns an action that copies a data set/source pair.
 * @param {String} fromSourceName Name of the set/source pair to copy
 * @param {String} toTargetName Name of the new (copy) set/source pair
 */
export const copyDataSetAction = (fromSourceName, toTargetName) => {
    return {
        type: DRAGONGLASS_DATA_SET_COPY,
        payload: {
            sourceName: fromSourceName,
            targetName: toTargetName
        }
    };
};

/**
 * Returns an action that deletes a data set/source pair.
 * @param {String} name Name of the data source/set to delete
 */
export const deleteDataSetAction = name => {
    return {
        type: DRAGONGLASS_DATA_SET_DELETE,
        payload: name
    };
};

/**
 * Toggles the _selected state for a row in a data set.
 * @param {String} source Name of the data source
 * @param {String} position Position key of the row
 */
export const toggleSelectionAction = (source, position) => {
    return {
        type: DRAGONGLASS_DATA_SET_TOGGLESELECTION,
        payload: { source, position }
    };
};

/**
 * Resets data sets to their initial state (deletes rows, sets current position to null)
 */
export const resetDataSets = () => {
    return {
        type: DRAGONGLASS_DATA_RESET_SETS
    };
};