import { useState } from "react";

let controls = {};
const getNextControlId = (controlType) => {
  if (!controls[controlType]) {
    controls[controlType] = 0;
  }
  return controls[controlType]++;
};

/**
 * Retrieves a unique ID for a control that stays the same throughout all render cycles as long as control is "alive".
 */
export default (controlType = "control") => {
  const [id] = useState(() => `${controlType}-${getNextControlId(controlType)}`);
  return id;
};
