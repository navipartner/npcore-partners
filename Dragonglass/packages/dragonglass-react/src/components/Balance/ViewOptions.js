import React from "react";
import { useSelector } from "react-redux";
import { balancingSelectConfirmedByPaymentType } from "../../redux/balancing/balancing-selectors";

const PaymentTypeOption = ({ paymentType, active, onClick }) => {
  const confirmed = useSelector(balancingSelectConfirmedByPaymentType(paymentType.paymentTypeNo));

  const paymentTypeIcon = confirmed ? (
    <i className="fa-light fa-circle-check payment-type-selection__icon-confirmed"></i>
  ) : (
    <i className="fa-light fa-circle-exclamation payment-type-selection__icon-danger"></i>
  );

  return (
    <span
      className={`payment-type-selection__option ${active ? "payment-type-selection__option--active" : ""}`}
      onClick={onClick}
    >
      {paymentTypeIcon} {paymentType.description}
    </span>
  );
};

export default function ViewOptions({
  state,
  activePaymentTypeIndex,
  switchActivePaymentType,
  toggleTableView,
  showTableView,
}) {
  return (
    <div className="counting__view-options">
      <div className="layouts">
        <div className={`layouts__option ${!showTableView ? "active" : ""}`} onClick={() => toggleTableView(false)}>
          <i className="fa-light fa-grid-2"></i>
        </div>
        <div className={`layouts__option ${showTableView ? "active" : ""}`} onClick={() => toggleTableView(true)}>
          <i className="fa-light fa-list-ul"></i>
        </div>
      </div>
      {!showTableView && (
        <div className="payment-type-selection">
          {state.counting.map((paymentType, index) => (
            <PaymentTypeOption
              paymentType={paymentType}
              key={index}
              active={index === activePaymentTypeIndex}
              onClick={() => switchActivePaymentType(index)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
