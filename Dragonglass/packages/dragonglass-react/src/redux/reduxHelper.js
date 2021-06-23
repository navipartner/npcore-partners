import { connect } from "react-redux";

function getObjectPartFromPath(path, obj) {
    const parts = path.split(".");
    let result = obj;
    try {
        for (let part of parts) {
            if (result.hasOwnProperty(part))
                result = result[part];
        }
        return result;
    }
    catch(e) {
        console.error(e);
        return null;
    }
};

const dynamicMap = {
    state: (state, ownProps) => {
        if (typeof ownProps.bindToState !== "string")
            return {
                boundState: {
                    state: null,
                    bound: false
                }
            };

        const boundState = getObjectPartFromPath(ownProps.bindToState, state);
        return {
            boundState: {
                state: boundState,
                bound: boundState !== null
            }
        };
    }
}

/*
 * These functions cannot be moved to dragonglass-redux because they invoke connect from react-redux, and that function cannot be
 * accessed from outside a <Provider>
 * These have to remain in this project.
 */

/**
 * Binds a component to a map descriptor object that contains definitions for state mapping, dispatch mapping as well
 * as an enhancer object that can be used to provided enhanced connect functionality (e.g. state equality check, etc.)
 * @param {Component} component Component to be bound to property/dispatch/enhancer map
 * @param {Object} map Map descriptor object containing map definitions { state: function, dispatch: function, enhancer: object }
 */
export const bindToMap = (component, map) =>
    connect(map.state, map.dispatch, null, map.enhancer)(component);

export const bindToMapExtended = (component, map, extended) =>
    connect((state, ownProps) => map.state(state, ownProps, extended), map.dispatch, null, map.enhancer)(component);

export const bindToStateDynamic = component => bindToMap(component, dynamicMap);