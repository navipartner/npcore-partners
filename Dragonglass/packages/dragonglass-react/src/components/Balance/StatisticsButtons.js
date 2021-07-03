import React from "react";
import { localize } from "../LocalizationManager";
import { balancingSelectConfirmed, balancingState } from "../../redux/balancing/balancing-selectors";
import { setBalancingState } from "./BackEndActions";
import { StateStore } from "../../redux/StateStore";
import { Popup } from "../../dragonglass-popup/PopupHost";
import { useSelector } from "react-redux";

export default function StatisticsButtons({ onCashCountClick }) {
  const confirmed = useSelector(balancingSelectConfirmed);

  const close = async (closeClicked) => {
    let completeClose = true;
    if (!confirmed) {
      completeClose = await Popup.confirm(localize("Balancing_NotCompletedConfirmation"));
    }
    if (!completeClose) {
      return;
    }
    setBalancingState(balancingState(StateStore.getState()), !!closeClicked);
  };

  return (
    <div className="buttons">
      <div className="buttons__container">
        <div className="button">
          <i className="fa-light fa-print"></i> {localize("Balancing_ButtonPrintStatistics")}
        </div>
        <div
          className={`button ${confirmed ? "button--confirmed" : "button--not-confirmed"}`}
          onClick={onCashCountClick}
        >
          {confirmed ? (
            <>
              <i className="fa-light fa-circle-check"></i> {localize("Balancing_ButtonCashCount")}
            </>
          ) : (
            <>
              <i className="fa-light fa-circle-exclamation"></i>{" "}
              <span>
                {localize("Balancing_ButtonCashCount")} {localize("Balancing_ButtonCashCountNotCompleted")}
              </span>
            </>
          )}
        </div>
      </div>
      <div className="buttons__container">
        <div className="button" onClick={() => close(true)}>
          {localize("Balancing_ButtonComplete")}
        </div>
        <div className="button" onClick={() => close(false)}>
          {localize("Global_Cancel")}
        </div>
      </div>
    </div>
  );
}
