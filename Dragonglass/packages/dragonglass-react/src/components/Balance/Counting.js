import React, { useState } from "react";
import { useSelector } from "react-redux";
import { balancingSelectCashCount } from "../../redux/balancing/balancing-selectors";
import CoinTypesModal from "./CoinTypesModal";
import ViewOptions from "./ViewOptions";
import ContentDefaultView from "./ContentDefaultView";
import NothingToDoHere from "./NothingToDoHere";
import ContentTableView from "./ContentTableView";
import Buttons from "./Buttons";

export default function Counting({ layout, onCloseClick, renderAsModal }) {
  const [isCoinTypesModalVisible, setCoinTypesModalVisibility] = useState(false);
  const [showTableView, setTableView] = useState(false);
  const [activePaymentTypeIndex, setActivePaymentTypeIndex] = useState(0);

  const state = useSelector(balancingSelectCashCount);

  const updateCoinTypeCounting = (total) => {
    setCoinTypesModalVisibility(false);
  };

  const displayCoinTypes = () => {
    setCoinTypesModalVisibility(true);
  };

  const switchActivePaymentType = (newIndex) => {
    setActivePaymentTypeIndex(newIndex);
  };

  const toggleTableView = (tableVisibility) => {
    setTableView(tableVisibility);
  };

  let countingContent = showTableView ? (
    <ContentTableView state={state} layout={layout} displayCoinTypes={displayCoinTypes} onCloseClick={onCloseClick} />
  ) : (
    <ContentDefaultView
      state={state}
      layout={layout}
      activePaymentTypeIndex={activePaymentTypeIndex}
      displayCoinTypes={displayCoinTypes}
    />
  );

  return (
    <div className={`counting-backdrop ${renderAsModal ? "counting-backdrop--modal" : ""}`}>
      <div className={`counting ${renderAsModal ? "counting--modal" : ""}`}>
        {state.counting.length && state.closingAndTransfer.length ? (
          <>
            {isCoinTypesModalVisible && (
              <CoinTypesModal
                coinTypes={state.counting[activePaymentTypeIndex].coinTypes}
                onClose={updateCoinTypeCounting}
                paymentTypeNo={state.counting[activePaymentTypeIndex].paymentTypeNo}
              />
            )}
            <ViewOptions
              state={state}
              activePaymentTypeIndex={activePaymentTypeIndex}
              switchActivePaymentType={switchActivePaymentType}
              toggleTableView={toggleTableView}
              switchActivePaymentType={switchActivePaymentType}
              showTableView={showTableView}
            />
            {countingContent}
            <Buttons onCloseClick={onCloseClick} />
          </>
        ) : (
          <NothingToDoHere onCloseClick={onCloseClick} />
        )}
      </div>
    </div>
  );
}
