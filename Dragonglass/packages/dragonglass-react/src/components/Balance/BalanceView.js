import React, { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import { balancingSelectBackEndContext, balancingSelectView, balancingViewStateEqual } from "../../redux/balancing/balancing-selectors";
import Statistics from "./Statistics";
import Counting from "./Counting/Counting";
import { getBalancingState } from "./BackEndActions";

export const BalanceView = ({ isStatisticsEnabled }) => {
  const state = useSelector(balancingSelectView, balancingViewStateEqual);
  const backEndState = useSelector(balancingSelectBackEndContext);

  isStatisticsEnabled = isStatisticsEnabled || true; //TODO: remove once we start using a prop for this

  const [showCounting, setShowCounting] = useState(!isStatisticsEnabled);

  useEffect(() => {
    getBalancingState(backEndState);
  }, []);

  return (
    <div className="balance-view">
      {isStatisticsEnabled && <Statistics layout={state.statistics} onCashCountClick={() => setShowCounting(true)} />}

      {showCounting && (
        <Counting
          layout={state.cashCount}
          onCloseClick={() => setShowCounting(false)}
          renderAsModal={isStatisticsEnabled}
        />
      )}
    </div>
  );
};
