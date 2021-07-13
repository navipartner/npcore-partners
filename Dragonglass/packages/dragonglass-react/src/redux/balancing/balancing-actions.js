import { StateStore } from "../StateStore";

/** Updates the balancing screen state from the back end */
export const DRAGONGLASS_BALANCING_UPDATE_STATE = "DRAGONGLASS_BALANCING_UPDATE_STATE";

/** Updates the calculated values during balancing */
export const DRAGONGLASS_BALANCING_UPDATE_VALUES = "DRAGONGLASS_BALANCING_UPDATE_VALUES";

/** Updates the confirmed status for balancing of a payment type */
export const DRAGONGLASS_BALANCING_CONFIRM_PAYMENT_TYPE = "DRAGONGLASS_BALANCING_CONFIRM_PAYMENT_TYPE";

/** Updates coin type counting */
export const DRAGONGLASS_BALANCING_UPDATE_COIN_TYPES = "DRAGONGLASS_BALANCING_UPDATE_COIN_TYPES";

/** Updates back-end context */
export const DRAGONGLASS_UPDATE_BACK_END_CONTEXT = "DRAGONGLASS_UPDATE_BACK_END_CONTEXT";

const updateState = (payload) => ({
  type: DRAGONGLASS_BALANCING_UPDATE_STATE,
  payload,
});

const updateValues = (payload) => ({
  type: DRAGONGLASS_BALANCING_UPDATE_VALUES,
  payload,
});

const confirmPaymentType = (paymentTypeNo) => ({
  type: DRAGONGLASS_BALANCING_CONFIRM_PAYMENT_TYPE,
  payload: paymentTypeNo,
});

const updateCoinTypes = (paymentTypeNo, coinTypes) => ({
  type: DRAGONGLASS_BALANCING_UPDATE_COIN_TYPES,
  payload: { paymentTypeNo, coinTypes },
});

const updateBackEndContext = (context) => ({
  type: DRAGONGLASS_UPDATE_BACK_END_CONTEXT,
  payload: context
});

/** Defines the balancing screen state actions */
export const balancingActions = {
  /**
   * Updates balancing state
   */
  updateState: (payload) => StateStore.dispatch(updateState(payload)),

  /**
   * Updates balancing values (during counting)
   */
  updateValues: (payload) => StateStore.dispatch(updateValues(payload)),

  /**
   * Confirms balancing for payment type
   */
  confirmCounting: (paymentTypeNo) => StateStore.dispatch(confirmPaymentType(paymentTypeNo)),

  /**
   * Updates coin types
   */
  updateCoinTypes: (paymentTypeNo, coinTypes) => StateStore.dispatch(updateCoinTypes(paymentTypeNo, coinTypes)),

  /**
   * Updates back-end balancing context
   */
  updateBackEndContext: (context) => StateStore.dispatch(updateBackEndContext(context)),
};
