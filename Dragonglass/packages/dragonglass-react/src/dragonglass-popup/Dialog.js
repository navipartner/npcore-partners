import React, { Component } from "react";
import { DialogType } from "./enums/DialogType";
import { DialogMessage } from "./dialogs/DialogMessage";
import { DialogError } from "./dialogs/DialogError";
import { DialogConfirm } from "./dialogs/DialogConfirm";
import { DialogNumpad } from "./dialogs/DialogNumpad";
import { DialogMenu } from "./dialogs/DialogMenu";
import { DialogCalendarPlusGrid } from "./dialogs/DialogCalendarPlusGrid";
import { DialogInput } from "./dialogs/DialogInput";
import { DialogOptionsMenu } from "./dialogs/DialogOptionsMenu";
import { DialogConfiguration } from "./dialogs/DialogConfiguration";
import { DialogSeatingSetup } from "./dialogs/restaurant/DialogSeatingSetup";
import { DialogSplitBill } from "./dialogs/split-bill/DialogSplitBill";
import { DialogConfigurationTable } from "./dialogs/DialogConfigurationTable";
import { DialogTimeout } from "./dialogs/DialogTimeout";
import { DialogCustom } from "./dialogs/DialogCustom";
import LocalizedCaption from "../components/LocalizedCaption";
import { DialogLookup } from "./dialogs/DialogLookup/DialogLookup";
import AnimatedContent from "./AnimatedContent";

const DialogConstructorsPerType = {
  [DialogType.INPUT]: DialogInput,
  [DialogType.MESSAGE]: DialogMessage,
  [DialogType.ERROR]: DialogError,
  [DialogType.CONFIRM]: DialogConfirm,
  [DialogType.NUMPAD]: DialogNumpad,
  [DialogType.MENU]: DialogMenu,
  [DialogType.CALENDAR_PLUS_GRID]: DialogCalendarPlusGrid,
  [DialogType.OPTIONS]: DialogOptionsMenu,
  [DialogType.CONFIGURATION]: DialogConfiguration,
  [DialogType.SEATING_SETUP]: DialogSeatingSetup,
  [DialogType.SPLIT_BILL]: DialogSplitBill,
  [DialogType.CONFIGURATION_TABLE]: DialogConfigurationTable,
  [DialogType.TIMEOUT]: DialogTimeout,
  [DialogType.CUSTOM_DIALOG]: DialogCustom,
  [DialogType.LOOKUP]: DialogLookup,
};

class DialogFactory {
  /**
   * Creates an instance of the DialogBase class, based on the type.
   *
   * @static
   * @param {Object} props Dialog properties
   * @returns {DialogBase} Instance of the matching dialog type
   * @memberof DialogFactory
   */
  static create(props) {
    return new DialogConstructorsPerType[props.type](props);
  }
}

const CustomClass = {
  [DialogType.INPUT]: "dialog__container--input",
  [DialogType.MESSAGE]: "dialog__container--message",
  [DialogType.ERROR]: "dialog__container--error",
  [DialogType.CONFIRM]: "dialog__container--confirm",
  [DialogType.NUMPAD]: "dialog__container--numpad",
  [DialogType.MENU]: "dialog__container--menu",
  [DialogType.CALENDAR_PLUS_GRID]: "dialog__container--calendarplusgrid",
  [DialogType.OPTIONS]: "dialog__container--options",
  [DialogType.CONFIGURATION]: "dialog__container--configuration",
  [DialogType.SEATING_SETUP]: "dialog__container--seating-setup",
  [DialogType.SPLIT_BILL]: "dialog__container--split-bill",
  [DialogType.CONFIGURATION_TABLE]: "dialog__container--configuration-table",
  [DialogType.TIMEOUT]: "dialog__container--timeout",
  [DialogType.CUSTOM_DIALOG]: "dialog__container--custom",
  [DialogType.LOOKUP]: "dialog__container--lookup",
};

export class Dialog extends Component {
  constructor(props) {
    super(props);

    this.state = {
      invalid: false,
      _updateCycle: 0,
    };

    this._refs = {
      dialog: React.createRef(),
      animatedContent: React.createRef(),
    };

    this.props._interface._alertInvalid = () => this._alertInvalid();
    this._dialog = DialogFactory.create(this.props);
    this._dialog.refreshUI = () =>
      this.setState({ _updateCycle: this.state._updateCycle + 1 });
    this._invalidTimeout = 0;
  }

  _scheduleResetInvalid() {
    if (this._invalidTimeout) return;

    this._invalidTimeout = setTimeout(() => {
      this._invalidTimeout = 0;
      this.setState({ invalid: false });
    }, 2000);
  }

  _alertInvalid() {
    if (this.state.invalid) {
      this._scheduleResetInvalid();
      return;
    }

    this.setState({ invalid: true });
    this._scheduleResetInvalid();
  }

  _onKeyUp(e) {
    if (!this.props.topmost) return;

    if (e.key === "Escape") {
      if (this._dialog.canDismissWithEscapeKeyPress()) this._dialog.dismiss();
      e.stopImmediatePropagation();
    }

    if (e.key === "Enter") {
      e.stopImmediatePropagation();
      if (this._dialog.canAcceptWithEnterKeyPress()) {
        this._dialog.accept();
        return;
      }
      this._alertInvalid();
    }
  }

  _onKeyDown(e) {
    if (!this.props.topmost) return;

    if (e.key === "Tab") {
      if (this._dialog.handleTabKey()) e.preventDefault();
    }
  }

  _onOverlayClicked() {
    if (!this.props.topmost) return;

    if (this._dialog.canDismissByClickingOutside()) {
      this._dialog.dismiss();
      return;
    }

    this._refs.animatedContent.current.triggerShake();
    this._alertInvalid();
  }

  _subscribeTopmostToOverlayClick() {
    const { topmost, overlayClickSubscribe } = this.props;
    if (topmost) {
      overlayClickSubscribe(() => this._onOverlayClicked());
    }
  }

  componentDidMount() {
    document.activeElement && document.activeElement.blur();
    this._refs.dialog.current.focus();

    this._keyUpCaptureListener = (e) => this._onKeyUp(e);
    document.addEventListener("keyup", this._keyUpCaptureListener, true);

    this._keyDownCaptureListener = (e) => this._onKeyDown(e);
    document.addEventListener("keydown", this._keyDownCaptureListener, true);

    this._dialog._componentDidMount();
  }

  componentWillUnmount() {
    document.removeEventListener("keyup", this._keyUpCaptureListener, true);
    document.removeEventListener("keydown", this._keyDownCaptureListener, true);
    this._dialog._componentWillUnmount();
  }

  render() {
    const { type, title, content } = this.props;
    const buttons = this._dialog.getButtons();

    this._subscribeTopmostToOverlayClick();

    const styleProvider = this._dialog.getCustomStyleProvider();
    const containerStyle = styleProvider
      ? styleProvider.getContainerStyle()
      : {};
    const bodyStyle = styleProvider ? styleProvider.getBodyStyle() : {};
    const buttonsStyle = styleProvider ? styleProvider.getButtonsStyle() : {};

    const additionalStyle = {};
    if (content && content.size) {
      if (content.size.width) {
        additionalStyle.width = content.size.width;
        additionalStyle.minWidth = "initial";
      }
      if (content.size.height) {
        additionalStyle.height = content.size.height;
        additionalStyle.minHeight = "initial";
      }
    }

    if (content.noScroll) {
      bodyStyle.height = bodyStyle.height || "100%";
    }

    return (
      <AnimatedContent
        dismissOnSwipeDown={() => this._onOverlayClicked()}
        canDismissByClickingOutside={this._dialog.canDismissByClickingOutside()}
        isTopMost={this.props.topmost}
        ref={this._refs.animatedContent}
        offset={this.props.offset}
      >
        <div
          style={{
            pointerEvents: "initial",
            ...containerStyle,
            ...additionalStyle,
          }}
          ref={this._refs.dialog}
          className={`dialog__container ${CustomClass[type]} ${
            this.state.invalid ? "dialog__container--invalid" : ""
          }`.trim()}
        >
          {this._dialog.canDismissByClickingOutside() && (
            <div className="dialog__swipe-handle"></div>
          )}
          {typeof title === "string" && title ? (
            <div className="dialog__titlebar">
              <span>
                {title.startsWith("l$.") ? (
                  <LocalizedCaption caption={title.substring(3)} />
                ) : (
                  title
                )}
              </span>
            </div>
          ) : null}

          <div style={{ ...bodyStyle }} className="dialog__body">
            {this._dialog.getBody()}
          </div>

          {buttons ? (
            <div style={{ buttonsStyle }} className="dialog__buttons">
              {buttons}
            </div>
          ) : null}
        </div>
      </AnimatedContent>
    );
  }
}
