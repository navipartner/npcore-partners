import React from "react";
import { InputType, inputTypeToDataType } from "../enums/InputType";
import Input from "../../components/Input";
import { DialogBase } from "./DialogBase";
import { DialogButtons } from "./DialogButtons";
import { ButtonEnableProxy } from "./ButtonEnableProxy";
import { Focus } from "../../components/FocusManager";
import { localize, GlobalCaption } from "../../components/LocalizationManager";
import { isMobile } from "../../classes/functions";

export class DialogInput extends DialogBase {
  constructor(props) {
    super(props);

    this._content.type = this._content.type || this.defaultInputType;
    this._inputType = "text";
    if (this._content.masked) this._inputType = "password";

    this._refs = {
      input: React.createRef(),
    };

    this._okEnabler = new ButtonEnableProxy(true);
    this._focusMounted = false;
  }

  componentDidMount() {
    if (!isMobile()) {
      Focus.require(this._refs.input.current.htmlInputControl);
      this._focusMounted = true;
    }
  }

  componentWillUnmount() {
    if (this._focusMounted) {
      Focus.release(this._refs.input.current.htmlInputControl);
    }
  }

  get defaultInputType() {
    return InputType.TEXT;
  }

  get inputBox() {
    return this._refs.input.current;
  }

  /**
   * Provides an override point for custom dialogs to provide additional data validation logic during editing.
   * If this function returns false, the entry is deemed invalid and this is visually indicated on screen.
   *
   * @param {*} value Value to validate
   * @returns {Boolean} Boolean result of additional validation.
   */
  getExtendedValidationResult(value) {
    return !this._content.required || !!value;
  }

  _getValue(value) {
    return InputType.behavior[this._content.type].calculate(
      value === undefined ? this._refs.input.current.value : value
    );
  }

  accept() {
    this._interface.close(this._getValue());
  }

  dismiss() {
    this._interface.close(null);
  }

  canDismissByClickingOutside() {
    return false;
  }

  canAcceptWithEnterKeyPress() {
    return this._okEnabler.enabled;
  }

  handleTabKey() {
    this._refs.input.current.htmlInputControl.focus();
    return true;
  }

  /**
   * Override in descendant classes to provide custom content before caption
   */
  getBodyContentBeforeCaption() {
    return null;
  }

  /**
   * Override in descendant classes to provide custom content before input box
   */
  getBodyContentBeforeInput() {
    return null;
  }

  /**
   * Override in descendant classes to provide custom content after input box
   */
  getBodyContentAfterInput() {
    return null;
  }

  _enableAccept(value, fullyValid) {
    this._okEnabler.enabled = fullyValid && this.getExtendedValidationResult(value);
  }

  getBody() {
    const { caption, value, type } = this._content;
    return (
      <>
        {this.getBodyContentBeforeCaption()}
        <span dangerouslySetInnerHTML={{ __html: caption }} />
        {this.getBodyContentBeforeInput()}
        <Input
          onChange={(value, fullyValid) => this._enableAccept(value, fullyValid)}
          value={value || ""}
          inputType={this._inputType}
          dataType={inputTypeToDataType(type)}
          ref={this._refs.input}
          erase={true}
        />
        {this.getBodyContentAfterInput()}
      </>
    );
  }

  getButtons() {
    return (
      <DialogButtons
        buttons={[
          {
            id: "button-dialog-ok",
            caption: localize(GlobalCaption.FromBackEnd.Global_OK),
            click: this.accept.bind(this),
            enabler: this._okEnabler,
          },
          {
            id: "button-dialog-cancel",
            caption: localize(GlobalCaption.FromBackEnd.Global_Cancel),
            click: this.dismiss.bind(this),
          },
        ]}
      />
    );
  }
}
