import React from "react";
import { useSelector } from "react-redux";
import { balancingActions } from "../../../redux/balancing/balancing-actions";
import { balancingSelectConfirmedByPaymentType } from "../../../redux/balancing/balancing-selectors";

export const CountingConfirmButton = ({ paymentType }) => {
  const confirmed = useSelector(balancingSelectConfirmedByPaymentType(paymentType.paymentTypeNo));

  return confirmed ? (
    <div className="input-icon input-icon--confirmed">
      <i className="fa-light fa-square-check"></i>
    </div>
  ) : (
    <div className="input-icon" onClick={() => balancingActions.confirmCounting(paymentType.paymentTypeNo)}>
      <i className="fa-light fa-square"></i>
    </div>
  );
};
