import { useSelector } from "react-redux";
import { NAVEventFactory } from "dragonglass-nav";
import { lookupSelectSubstate } from "./lookup-selectors";
import { lookupActions } from "./lookup-actions";

let backEndMethod;

const errorResponse = {};

const initializeBackEndInfrastructureIfNecessary = () => {
  if (backEndMethod) {
    return;
  }
  backEndMethod = NAVEventFactory.method({ name: "LookupFromPOS", forceAsync: true, awaitResponse: true });
};

const invokeBackEnd = async (showCount, controlId, type, context) => {
  if (errorResponse[controlId] && errorResponse[showCount]) {
    // If there was a lookup error for this control and this show count, then we don't want to force more loads
    return;
  }

  initializeBackEndInfrastructureIfNecessary();
  const response = await backEndMethod.raise({ type, ...context });
  if (backEndMethod.isError(response)) {
    if (!errorResponse[controlId]) {
      errorResponse[controlId] = {};
    }
    errorResponse[controlId][showCount] = true;
    return;
  }
  lookupActions.updateState({ ...response, showCount, controlId });
};

export const useLookup = (showCount, controlId, type, batchSize = 0) => {
  const state = useSelector(lookupSelectSubstate(type));

  const loadMore = (checkOnly) => {
    invokeBackEnd(showCount, controlId, type, { generation: state.generation, skip: state.data.length, checkOnly });
  };

  const wrapWithLoadMore = (result) => {
    result = [...result];
    result.loadMore = () => loadMore();
    result.completed = !!(state || {}).completed;
    return result;
  };

  if (!state) {
    invokeBackEnd(showCount, controlId, type, { generation: -1, batchSize, skip: 0 });
    return [];
  }

  const knownShowCount = state.showCount[controlId] || 1;
  if (knownShowCount !== showCount) {
    // When show count for a control changes, we need to send a pre-emptive back-end invocation to check if any data needs refreshing
    loadMore(true);
  }

  return wrapWithLoadMore(state.data);
};
