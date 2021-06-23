import { createReducer } from "dragonglass-redux";
import { DRAGONGLASS_LOOKUP_UPDATE } from "./lookup-actions";
import initialState from "./lookup-initial";

export default createReducer(initialState, {
  [DRAGONGLASS_LOOKUP_UPDATE]: (state, payload) => {
    let { type, fullRefresh, generation, moreDataAvailable, data, controlId, showCount } = payload;
    const result = { ...state };

    if (!fullRefresh) {
      const existing = (result[type] && result[type].data) || [];
      data = [...existing, ...data];
    }

    result[type] = { generation, completed: !moreDataAvailable, data };
    result[type].showCount = { ...(result[type].showCount || {}), [controlId]: showCount };
    return result;
  },
});
