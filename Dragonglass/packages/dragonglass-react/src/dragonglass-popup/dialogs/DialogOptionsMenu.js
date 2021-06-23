import React from "react";
import { DialogBase } from "./DialogBase";
import Button from "../../components/Button";
import { DialogButtons } from "./DialogButtons";
import { ButtonEnableProxy } from "./ButtonEnableProxy";
import SimpleBar from "simplebar-react";
import { PopupRuntimeError } from "../PopupError";
import { localize, GlobalCaption } from "../../components/LocalizationManager";

export class DialogOptionsMenu extends DialogBase {
  constructor(props) {
    super(props);

    // Validate configuration
    if (this._content.multiSelect && this._content.oneTouch)
      throw new PopupRuntimeError(
        "[DialogOptionsMenu] You cannot specify both multiSelect and oneTouch at the same time."
      );

    this.state = {
      selected: [],
    };

    this._okEnabler = new ButtonEnableProxy(false);
  }

  _handleClick(option) {
    if (this._content.oneTouch) {
      this._interface.close(option);
    } else {
      let newState;
      if (this.state.selected.includes(option)) {
        newState = this._content.multiSelect
          ? {
              selected: this.state.selected.filter(
                (existing) => existing !== option
              ),
            }
          : { selected: [] };
      } else {
        newState = this._content.multiSelect
          ? { selected: [...this.state.selected, option] }
          : { selected: [option] };
      }
      this._okEnabler.enabled = newState.selected.length;
      this.setState(newState);
    }
  }

  accept() {
    this._interface.close(
      this._content.multiSelect ? this.state.selected : this.state.selected[0]
    );
  }

  dismiss() {
    this._interface.close(null);
  }

  canAcceptWithEnterKeyPress() {
    return !this._content.oneTouch && this._okEnabler.enabled;
  }

  getBody() {
    return (
      <div
        className={`buttongrid dialog__options__body ${
          this._content.vertical
            ? "buttongrid dialog__options__body--vertical"
            : ""
        }`}
      >
        <SimpleBar>
          <div className="buttongrid__row">
            {this._content.options.map((option, index) => {
              const props = {
                key: index,
                id: index,
                caption: option && option.caption ? option.caption : option,
              };
              if (option.icon) props.button = { iconClass: option.icon };
              if (this.state.selected.includes(option)) props.selected = true;

              return (
                <Button onClick={() => this._handleClick(option)} {...props} />
              );
            })}
          </div>
        </SimpleBar>
      </div>
    );
  }

  getButtons() {
    return this._content.oneTouch ? null : (
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
