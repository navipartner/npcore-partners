import React from "react";
import Numpad from "../../components/Numpad";
import { DialogInput } from "./DialogInput";
import { InputType } from "../enums/InputType";

export class DialogNumpad extends DialogInput {
  get defaultInputType() {
    return this._content.inputType || InputType.DECIMAL;
  }

  getExtendedValidationResult(value) {
    const val = this._getValue(value);
    if (
      this._content.hasOwnProperty("minValue") &&
      val < this._content.minValue
    ) {
      return false;
    }

    if (
      this._content.hasOwnProperty("maxValue") &&
      val > this._content.maxValue
    ) {
      return false;
    }
    return true;
  }

  getBodyContentAfterInput() {
    return (
      <Numpad
        enterValueFunction={(value) =>
          this.inputBox.insertValueAtCurrentPosition(value)
        }
      />
    );
  }
}
