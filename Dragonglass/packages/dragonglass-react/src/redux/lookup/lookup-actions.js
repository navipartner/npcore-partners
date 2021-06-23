import { StateStore } from "../StateStore";

/** Updates the lookup state from the back end */
export const DRAGONGLASS_LOOKUP_UPDATE = "DRAGONGLASS_LOOKUP_UPDATE";

export const update = (payload) => ({
  type: DRAGONGLASS_LOOKUP_UPDATE,
  payload,
});

/** Defines the lookup actions */
export const lookupActions = {
  /**
   * Updates the lookup state from the back end
   * @param {Any} payload Payload to send to the action
   */
  updateState: (payload) => StateStore.dispatch(update(payload)),
};
