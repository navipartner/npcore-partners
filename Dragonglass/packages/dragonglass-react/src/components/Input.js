import React, { Component } from "react";
import Label from "./Label";
import { DataType } from "../enums/DataType";
import { localize, GlobalCaption } from "./LocalizationManager";
import TextEnterHost from "../dragonglass-textenter/TextEnterHost";
import { isMobile } from "../classes/functions";

const classNames = {
  textboxHolder: "input__holder",
  textbox: "input__textbox",
};

class Input extends Component {
  constructor(props) {
    super(props);
    this._refs = {
      input: React.createRef(),
      holder: React.createRef(),
      notification: React.createRef(),
    };
    this._dataType = this.props.dataType || DataType.STRING;
    this._dataTypeMethods = DataType.behavior[this._dataType];
    this._invalidTimeout = 0;
  }

  shouldComponentUpdate() {
    // Since we manipulate the styles and the input content directly, we don't want any re-rendering of this component.
    return false;
  }

  componentDidMount() {
    this._initialValue = this._dataTypeMethods.format(this.props.value || "");
    this._refs.input.current.value = this._initialValue;
    this._refs.input.current.select();
    this._keyUpCaptureListener = (e) => this._keyUpCapture(e);
    this._refs.input.current.addEventListener(
      "keyup",
      this._keyUpCaptureListener,
      true
    );
    this._onChange();
    this._enteringValue = false;
  }

  componentWillUnmount() {
    this._refs.input.current.removeEventListener(
      "keyup",
      this._keyUpCaptureListener,
      true
    );
  }

  _onChange() {
    if (typeof this.props.onChange !== "function") return;

    if (this.props.simple && this._dataType === DataType.STRING) {
      this.props.onChange(value, true);
      return;
    }

    const value = this.value;
    const valid = this._dataTypeMethods.isValidValue(value);
    this.props.onChange(value, valid);
    this._indicateCalculatedValue();
  }

  _setCalculatedValueCaption() {
    if (this._isCalculated)
      this._refs.notification.current.innerText = `${localize(
        GlobalCaption.Input.ResultIs
      )}: ${this._dataTypeMethods.format(
        this._dataTypeMethods.calculate(this.value)
      )}`;
    else this._refs.notification.current.innerHTML = "&nbsp;";
  }

  _indicateCalculatedValue() {
    setTimeout(() => {
      this._isCalculated = this._dataTypeMethods.isCalculated(this.value);
      if (this._invalidTimeout) return;

      this._setCalculatedValueCaption();
    });
  }

  _resetInvalid() {
    if (this._invalidTimeout) clearTimeout(this._invalidTimeout);
    this._invalidTimeout = 0;
    this._refs.holder.current.className = classNames.textboxHolder;
    this._refs.input.current.className = classNames.textbox;
    this._setCalculatedValueCaption();
  }

  _isValidVisualFeedback(valid, newVal) {
    if (valid) {
      this._resetInvalid();
      return;
    }

    this._refs.notification.current.innerText = `"${newVal}" ${localize(
      GlobalCaption.Input.InvalidValue
    )}`;
    this._refs.holder.current.className = `${classNames.textboxHolder} ${classNames.textboxHolder}--invalid`;
    this._refs.input.current.className = `${classNames.textbox} ${classNames.textbox}--invalid`;
    if (this._invalidTimeout) clearTimeout(this._invalidTimeout);

    this._invalidTimeout = setTimeout(() => this._resetInvalid(), 5000);
  }

  _isValidNewValue(newVal) {
    if (this.props.simple && this._dataType === DataType.STRING) return true;

    const newValid = this._dataTypeMethods.isValidDuringEntry(newVal);
    this._isValidVisualFeedback(newValid, newVal);

    return newValid;
  }

  get value() {
    return this._refs.input.current.value;
  }

  get htmlInputControl() {
    return this._refs.input.current;
  }

  insertValueAtCurrentPosition(value) {
    const input = this._refs.input.current;

    if (isMobile()) {
      let val = this._enteringValue ? input.value + value : value;
      this._enteringValue = true;
      if (this._isValidNewValue(val)) {
        input.value = val;
        this._onChange();
      }
      return;
    }

    typeof value !== "string" && (value = `${value}`);
    let active = document.activeElement;
    if (active && active !== input) {
      input.focus();
    }

    let len = input.value.length;
    let start = input.selectionStart;
    let end = input.selectionEnd;
    let val = input.value
      .substring(0, start)
      .concat(value, input.value.substring(end, len));
    if (this._isValidNewValue(val)) {
      input.value = val;
      input.selectionStart = start + value.length;
      input.selectionEnd = start + value.length;
      this._onChange();
    }
    input.focus();
  }

  _clear() {
    this._refs.input.current.value = "";
    this._onChange();
    this._enteringValue = false;
    if (!isMobile()) {
      this._refs.input.current.focus();
    }
  }

  _clickClear() {
    this._clear();
  }

  _keyDown(e) {
    if (this.props.simple && this._dataType === DataType.STRING) return;

    if (e.altKey || e.ctrlKey || e.metaKey) return;

    if (e.key.length > 1) return;

    if (this._dataType === DataType.STRING) return;

    const input = this._refs.input.current;
    let len = input.value.length;
    let start = input.selectionStart;
    let end = input.selectionEnd;
    let val = input.value
      .substring(0, start)
      .concat(e.key, input.value.substring(end, len));
    if (!this._isValidNewValue(val)) {
      e.preventDefault();
      e.stopPropagation();
      return;
    }
  }

  _keyUpCapture(e) {
    if (e.key === "Escape") {
      if (this.value !== this._initialValue) {
        this._refs.input.current.value = this._initialValue;
        e._dragonglass_handled = true;
        e.preventDefault();
        e.stopPropagation();
        this._onChange();
      }
    }
  }

  _keyUp(e) {
    if (e.key === "Enter" && !e.altKey && !e.ctrlKey && !e.shiftKey) {
      const { onEnter, textEnter, clearOnEnter, blurOnEnter } = this.props;

      if (typeof onEnter === "function") {
        onEnter(this.value);
      }

      if (typeof textEnter === "function") {
        textEnter.apply(this);
      }

      if (clearOnEnter) {
        this._clear();
      }

      if (blurOnEnter) {
        this._refs.input.current.blur();
      }
    }
  }

  _paste(e) {
    if (this.props.simple && this._dataType === DataType.STRING) return;

    if (this._dataType === DataType.STRING) return;

    const paste = (e.clipboardData || window.clipboardData).getData("text");
    const input = this._refs.input.current;
    let len = input.value.length;
    let start = input.selectionStart;
    let end = input.selectionEnd;
    let val = input.value
      .substring(0, start)
      .concat(paste, input.value.substring(end, len));
    if (!this._isValidNewValue(val)) {
      e.preventDefault();
      e.stopPropagation();
      return;
    }
  }

  render() {
    const {
      id,
      layout,
      erase,
      inputType,
      textEnter,
      onFocus,
      autoFocus,
    } = this.props;
    let editable =
      typeof this.props.editable === "boolean" ? this.props.editable : true;

    if (autoFocus) {
      setTimeout(() => {
        const input = this._refs.input.current;
        input.focus();
      });
    }

    return (
      <div
        className={`input${
          layout && layout.caption ? " input--with-caption" : ""
        }`}
        id={id}
      >
        {/* Label */}
        {layout && layout.caption ? (
          <Label className="input__label" caption={layout.caption}></Label>
        ) : null}

        {/* Input control with input holder */}
        <div ref={this._refs.holder} className={classNames.textboxHolder}>
          <input
            ref={this._refs.input}
            readOnly={typeof editable === "boolean" ? !editable : false}
            className={classNames.textbox}
            type={inputType || "text"}
            onKeyDownCapture={(e) => this._keyDown(e)}
            onKeyUp={(e) => this._keyUp(e)}
            onPasteCapture={(e) => this._paste(e)}
            onChange={() => this._onChange()}
            onFocus={() => typeof onFocus === "function" && onFocus()}
            autoComplete="off"
          />
          {erase && editable && (
            <div onClick={() => this._clickClear()} className="input__erase">
              <i className="fa-light fa-xmark"></i>
            </div>
          )}
        </div>

        {/* TextEnterHost */}
        {typeof textEnter === "function" ? <TextEnterHost id={id} /> : null}

        {/* Input notification */}
        {this.props.simple ? null : (
          <div
            ref={this._refs.notification}
            className="input__notification"
            dangerouslySetInnerHTML={{ __html: "&nbsp;" }}
          ></div>
        )}
      </div>
    );
  }
}

export default Input;
