import React, { useState } from "react";
import { localize } from "../LocalizationManager";
import { InputWithLookup } from "../InputWithLookup";

export default function InlineProperty({
  layout,
  property,
  isEditable,
  type,
  setAsFocused,
  focusedInlineProperty,
  currentValue,
  updateNumberValue,
  updateTextValue,
  setSelected,
  deleteLastCharacter,
  inputIcon,
}) {
  const layoutProperty = layout.filter((item) => item.select === property)[0];

  const updateCurrentValue = (event) => {
    const value = event.target.value;

    if (keyPressed === "Backspace") {
      deleteLastCharacter();
    } else if (type === "number" && value) {
      updateNumberValue(value);
    } else {
      updateTextValue(value);
    }
  };

  const onKeyDown = (event) => {
    setKeyPressed(event.key);
  };

  const enableFocusAndSelectAll = (event) => {
    setAsFocused(property);
    setSelected(property);
    event.target.select();
  };

  const setInputValue = (value) => {
    updateTextValue(value);
  };

  const [keyPressed, setKeyPressed] = useState("");

  if (layoutProperty) {
    const label = layoutProperty ? localize(layoutProperty.label) : null;

    const value = isEditable ? (
      type === "lookup" ? (
        <InputWithLookup
          className="inline-property__input"
          onFocus={enableFocusAndSelectAll}
          onChange={updateCurrentValue}
          onRowClick={setInputValue}
          currentValue={currentValue}
          onBlur={() => setAsFocused("")}
        />
      ) : (
        <input
          className="inline-property__input"
          type={type}
          step="0.01"
          min="0"
          value={currentValue || ""}
          onFocus={enableFocusAndSelectAll}
          onClick={enableFocusAndSelectAll}
          onChange={updateCurrentValue}
          onKeyDown={onKeyDown}
        />
      )
    ) : (
      <input className="inline-property__input" value={currentValue || ""} disabled />
    );

    const isFocused = focusedInlineProperty === property;
    const isCentered = !currentValue && !isFocused;
    const isLookupAndFocused = type === "lookup" && isFocused;

    return (
      <div
        className={`inline-property ${!isEditable ? "inline-property--disabled" : ""} 
        ${isFocused ? "inline-property--focused" : ""} 
        ${isLookupAndFocused ? "inline-property--focused-lookup" : ""}`}
      >
        {currentValue !== undefined && (
          <div
            className={`inline-property__label ${
              isCentered ? "inline-property__label--centered" : "inline-property__label--minimized"
            }`}
          >
            {label}
          </div>
        )}
        <div className="inline-property__value">
          {inputIcon}
          {value}
        </div>
      </div>
    );
  }

  return null;
}
