import { NAVEventFactory } from "dragonglass-nav";
import { balancingActions } from "../../redux/balancing/balancing-actions";

let _getState = null;
let _setState = null;

export const getBalancingState = async (context) => {
  if (!_getState) {
    _getState = NAVEventFactory.method({
      name: "BalancingGetState",
      awaitResponse: true,
    });
  }

  const result = await _getState.raise(context);
  balancingActions.updateState(result);
};

export const setBalancingState = async (state, confirmed, backEndContext) => {
  if (!_setState) {
    _setState = NAVEventFactory.method("BalancingSetState");
  }

  _setState.raise({ state, confirmed, backEndContext });
};
