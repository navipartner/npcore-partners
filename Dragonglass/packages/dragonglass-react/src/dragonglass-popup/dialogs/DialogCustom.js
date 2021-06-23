import React from "react";
import { DialogBase } from "./DialogBase";
import { DialogButtons } from "./DialogButtons";
import SimpleBar from "simplebar-react";
import PlusMinusEditor from "../../components/PlusMinusEditor";
import Switch from "../../components/Switch";
import { IncorrectPopupConfigurationError } from "../../dragonglass-errors/IncorrectPopupConfigurationError";
import RadioGroup from "../../components/RadioGroup";
import CollapsibleGroup from "../../components/CollapsibleGroup";
import { DataType } from "../../enums/DataType";
import InputWithBinding from "../../components/InputWithBinding";
import Label from "../../components/Label";
import Icon from "../../components/Icon";
import Image from "../../components/Image";
import { QRCode } from "react-qr-svg";
import { localize, GlobalCaption } from "../../components/LocalizationManager";
import { GlobalErrorDispatcher } from "dragonglass-core";
import ButtonGrid from "../../components/ButtonGrid";
import { MenuButtonGridClickHandler } from "../../dragonglass-click-handlers/grid/MenuButtonGridClickHandler";

function getDefaultValue(setting) {
  if (setting.value) return setting.value;

  switch (setting.type) {
    case "plusminus":
      if (setting.minValue) return setting.minValue;
      return 0;

    case "switch":
      return false;

    case "radio":
      return setting.options[0].value;

    case "text":
      return "";

    case "integer":
      return 0;

    case "decimal":
      return 0;
  }
}

function validateSetting(setting, validation) {
  if (!validation._ids) validation._ids = [];

  if (typeof setting !== "object") {
    validation.push(`Invalid setting type: ${String(setting)}`);
    return false;
  }

  let result = true;

  if (!setting.id && setting.type !== "group") {
    validation.push(
      `Missing id in ${JSON.stringify(
        setting
      )}. Try adding a unique id, like this: ${JSON.stringify({
        id: "some_id_to_identify_this_setting",
        ...setting,
      })}`
    );
    result = false;
  }

  if (setting.id) {
    if (validation._ids.includes(setting.id)) {
      validation.push(
        `A non-unique id specified in ${JSON.stringify(
          setting
        )}. Each setting must have a unique id.`
      );
      result = false;
    }
    validation._ids.push(setting.id);
  }

  if (!setting.type) {
    validation.push(
      `Missing type in ${JSON.stringify(
        setting
      )}. Try defining a known type, like this: ${JSON.stringify({
        type: "setting_type",
        ...setting,
      })}`
    );
    result = false;
  }

  if (
    !setting.caption &&
    setting.type !== "icon" &&
    setting.type !== "image" &&
    setting.type !== "qr" &&
    setting.type !== "menu"
  ) {
    validation.push(
      `Missing caption in ${JSON.stringify(
        setting
      )}. Try defining a caption, like this: ${JSON.stringify({
        caption: "Some text to show on screen",
        ...setting,
      })}`
    );
    result = false;
  }

  switch (setting.type) {
    case "group":
      if (!setting.settings) {
        validation.push(
          `Missing settings in ${JSON.stringify(
            setting
          )}. Try defining an settings array, like this: ${JSON.stringify({
            settings: [{}, {}, {}],
            ...setting,
          })}`
        );
        result = false;
      }
      if (setting.settings && !Array.isArray(setting.settings)) {
        validation.push(
          `Incorrect settings configuration in ${JSON.stringify(
            setting
          )}, array expected.`
        );
        result = false;
      }
      break;
    case "plusminus":
      if (
        setting.hasOwnProperty("value") &&
        typeof setting.value !== "number"
      ) {
        validation.push(
          `Incorrect value type in ${JSON.stringify(setting)}, number expected.`
        );
        result = false;
      }
      if (
        setting.hasOwnProperty("minValue") &&
        typeof setting.minValue !== "number"
      ) {
        validation.push(
          `Incorrect minValue type in ${JSON.stringify(
            setting
          )}, number expected.`
        );
        result = false;
      }
      if (
        setting.hasOwnProperty("maxValue") &&
        typeof setting.maxValue !== "number"
      ) {
        validation.push(
          `Incorrect maxValue type in ${JSON.stringify(
            setting
          )}, number expected.`
        );
        result = false;
      }
      break;
    case "switch":
      if (
        setting.hasOwnProperty("value") &&
        typeof setting.value !== "boolean"
      ) {
        validation.push(
          `Incorrect value type in ${JSON.stringify(
            setting
          )}, boolean expected.`
        );
        result = false;
      }
      break;
    case "radio":
      if (!setting.options) {
        validation.push(
          `Missing options in ${JSON.stringify(
            setting
          )}. Try defining an options array, like this: ${JSON.stringify({
            options: [{}, {}, {}],
            ...setting,
          })}`
        );
        result = false;
      }
      if (setting.options && !Array.isArray(setting.options)) {
        validation.push(
          `Incorrect options configuration in ${JSON.stringify(
            setting
          )}, array expected.`
        );
        result = false;
      }
      if (
        setting.hasOwnProperty("vertical") &&
        typeof setting.vertical !== "boolean"
      ) {
        validation.push(
          `Incorrect vertical value in ${JSON.stringify(
            setting
          )}, boolean expected.`
        );
        result = false;
      }
      if (Array.isArray(setting.options)) {
        const values = [];
        setting.options.forEach((option) => {
          if (!option.caption) {
            validation.push(
              `Missing caption in option ${JSON.stringify(
                option
              )} in ${JSON.stringify(
                setting
              )}. Try defining a caption, like this: ${JSON.stringify({
                caption: "Some text to show on screen",
                ...option,
              })}`
            );
            result = false;
          }
          if (!option.value) {
            validation.push(
              `Missing value in option ${JSON.stringify(
                option
              )} in ${JSON.stringify(
                setting
              )}. Try defining a value, like this: ${JSON.stringify({
                value: "Some unique value",
                ...option,
              })}`
            );
            result = false;
          }
          if (option.value && values.includes(option.value)) {
            validation.push(
              `A non-unique value specified in option ${JSON.stringify(
                option
              )} in ${JSON.stringify(
                setting
              )}. Each radio option value must be unique.`
            );
            result = false;
          }
          values.push(option.value);
        });
      }
      break;
    case "text":
      break;
    case "decimal":
      break;
    case "integer":
      break;
    case "label":
      break;
    case "icon":
      break;
    case "image":
      if (!setting.src) {
        validation.push(`Missing src in ${JSON.stringify(setting)}`);
        result = false;
      }
      break;
    case "qr":
      if (!setting.qr || typeof setting.qr !== "object") {
        validation.push(`Missing qr definition in ${JSON.stringify(setting)}`);
        result = false;
      }
      break;
    case "menu":
      if (!setting.menu || typeof setting.menu !== "string") {
        validation.push(
          `Missing menu definition in ${JSON.stringify(setting)}`
        );
        result = false;
      }
      break;
    default:
      validation.push(
        `Unsupported type "${setting.type}" in ${JSON.stringify(
          setting
        )}. Check the documentation for the valid types.`
      );
      result = false;
  }

  return result;
}

export class DialogCustom extends DialogBase {
  constructor(props) {
    super(props);

    this._configuration = this._content.ui.reduce((prev, current) => {
      return current.type === "group"
        ? {
            ...prev,
            ...current.settings.reduce(
              (prev2, current2) => ({
                ...prev2,
                [current2.id]: getDefaultValue(current2),
              }),
              {}
            ),
          }
        : { ...prev, [current.id]: getDefaultValue(current) };
    }, {});

    this.state = {
      generation: 0,
    };

    function getControl(id, control) {
      for (var child of control) {
        if (child.id === id) return child;
        if (child.children) {
          var ctrl = getControl(id, child);
          if (ctrl) return ctrl;
        }
      }
    }

    this._content.__dialog_interface__.close = (result) =>
      this._interface.close(result);
    this._content.__dialog_interface__.update = (id, prop, value) => {
      let control = getControl(id, this._content.ui);
      if (control) {
        control[prop] = value;
        this.setState({ generation: this.state.generation + 1 });
        return true;
      }

      return false;
    };
    this._content.__dialog_interface__.effects = {
      rotate: (id, interval, degrees) => {
        let rotation = 0;
        let control = getControl(id, this._content.ui);
        setInterval(() => {
          rotation += degrees;
          if (rotation > 360) rotation -= 360;
          const style = { ...(control.style || {}) };
          style.transform = `rotate(${rotation}deg)`;
          control.style = style;
          this.setState({ generation: this.state.generation + 1 });
        }, interval);
      },
    };
  }

  accept() {
    this._interface.close(this._configuration);
  }

  canAcceptWithEnterKeyPress() {
    return false;
  }

  canDismissByClickingOutside() {
    return false;
  }

  _updateValue(key, value) {
    this._configuration[key] = value;
  }

  _renderSetting(settingRaw, index, validation) {
    if (!validateSetting(settingRaw, validation)) return null;

    const { type, id, ...setting } = settingRaw;

    switch (type) {
      case "plusminus":
        const additionalProps = {};
        if (setting.minValue) additionalProps.minValue = setting.minValue;
        if (setting.maxValue) additionalProps.maxValue = setting.maxValue;
        return (
          <PlusMinusEditor
            key={index}
            caption={setting.caption}
            {...additionalProps}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(id, value)}
          />
        );
      case "switch":
        return (
          <Switch
            key={index}
            id={id}
            caption={setting.caption}
            value={setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(id, value)}
          />
        );
      case "radio":
        return (
          <RadioGroup
            key={index}
            id={id}
            caption={setting.caption}
            options={setting.options}
            vertical={setting.vertical}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(id, value)}
          />
        );
      case "text":
        return (
          <InputWithBinding
            key={index}
            id={id}
            caption={setting.caption}
            dataType={DataType.STRING}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(id, value)}
          />
        );
      case "integer":
        return (
          <InputWithBinding
            key={index}
            id={id}
            caption={setting.caption}
            dataType={DataType.INTEGER}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(id, value)}
          />
        );
      case "decimal":
        return (
          <InputWithBinding
            key={index}
            id={id}
            caption={setting.caption}
            dataType={DataType.DECIMAL}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(id, value)}
          />
        );
      case "group":
        return (
          <CollapsibleGroup key={index} caption={setting.caption}>
            {setting.settings.map((setting, index) =>
              this._renderSetting(setting, index, validation)
            )}
          </CollapsibleGroup>
        );
      case "label":
        return <Label key={index} {...setting}></Label>;
      case "icon":
        return <Icon key={index} className={setting.class} {...setting} />;
      case "image":
        return (
          <Image
            key={index}
            className={setting.class}
            src={setting.src}
            {...setting}
          />
        );
      case "qr":
        return <QRCode key={index} {...setting.qr} />;
      case "menu":
        return (
          <ButtonGrid
            clickHandler={new MenuButtonGridClickHandler(() => this.accept())}
            layout={{
              source: setting.menu,
              rows: setting.rows || 1,
              columns: setting.columns || 5,
            }}
          />
        );
    }
  }

  getBody() {
    const validation = [];
    let settingsVDom = this._content.ui.map((setting, index) =>
      this._renderSetting(setting, index, validation)
    );
    if (validation.length) {
      GlobalErrorDispatcher.raiseCriticalError(
        new IncorrectPopupConfigurationError("configuration", validation)
      );
      settingsVDom = "(INVALID CONFIGURATION)";
    }

    const additional = {};
    if (this._content.bodyStyle) additional.style = this._content.bodyStyle;

    return (
      <div
        className={`dialog__settings__body ${
          this._content.vertical ? "dialog__settings__body--vertical" : ""
        }`}
        {...additional}
      >
        {this._content.caption ? (
          <div className="dialog__caption">
            <span dangerouslySetInnerHTML={{ __html: this._content.caption }} />
          </div>
        ) : null}
        {this._content.noScroll ? (
          <>{settingsVDom}</>
        ) : (
          <SimpleBar>{settingsVDom}</SimpleBar>
        )}
      </div>
    );
  }

  getButtons() {
    return this._content.oneTouch ? null : this._content.buttons ? (
      <DialogButtons
        buttons={
          this._content.buttons
            ? this._content.buttons.map((btn, index) => {
                const button = {
                  caption: btn.caption,
                };
                if (btn.icon) button.iconClass = btn.icon;

                const id = btn.id || `button-${index}`;

                return {
                  id: id,
                  button: button,
                  click: btn.click || this.accept.bind(this),
                };
              })
            : [
                {
                  id: "button-dialog-ok",
                  caption: localize(GlobalCaption.FromBackEnd.Global_OK),
                  click: this.accept.bind(this),
                },
                {
                  id: "button-dialog-cancel",
                  caption: localize(GlobalCaption.FromBackEnd.Global_Cancel),
                  click: this.dismiss.bind(this),
                },
              ]
        }
      />
    ) : null;
  }
}
