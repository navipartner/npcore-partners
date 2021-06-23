import React from "react";

export default function NothingToDoHere({ onCloseClick }) {
  return (
    <div className="nothing-to-do-here">
      <p>There is nothing to show here.</p>
      <p>Please check your setup in Business Central.</p>
      <div className="button" onClick={onCloseClick}>
        Close
      </div>
    </div>
  );
}
