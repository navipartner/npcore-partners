import React from "react";

export default function Buttons({ onCloseClick, paymentType }) {
  return (
    <div className="buttons">
      <div className="button" onClick={onCloseClick}>
        Close
      </div>
    </div>
  );
}
