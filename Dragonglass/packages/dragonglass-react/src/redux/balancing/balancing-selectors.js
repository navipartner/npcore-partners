/**
 * Retrieves the index of the currently selected page in mobile navigation bar. The index is relative to the default index.
 * @param {Object} state Current state of the Redux store.
 */
export const balancingSelectView = (state) => state.balancing.view;
export const balancingViewStateEqual = (left, right) => left === right;

export const balancingSelectStatistics = (state) => state.balancing.statistics;
export const balancingSelectCaption = (state) => state.balancing.caption;
export const balancingSelectCashCount = (state) => state.balancing.cashCount;
export const balancingState = (state) => state.balancing;

export const balancingSelectConfirmed = (state) =>
  Object.keys(state.balancing.cashCount.confirmed).reduce(
    (prev, curr) => prev && state.balancing.cashCount.confirmed[curr],
    true
  );

export const balancingSelectConfirmedByPaymentType = (paymentType) => (state) =>
  state.balancing.cashCount.confirmed[paymentType];
