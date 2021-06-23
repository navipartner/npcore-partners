import React from "react";
import { DialogBase } from "./DialogBase";
import { DialogButtons } from "./DialogButtons";
import SimpleBar from "simplebar-react";
import PlusMinusEditor from "../../components/PlusMinusEditor";
import Switch from "../../components/Switch";
import { IncorrectPopupConfigurationError } from "../../dragonglass-errors/IncorrectPopupConfigurationError";
import { GlobalErrorDispatcher } from "dragonglass-core";
import RadioGroup from "../../components/RadioGroup";
import CollapsibleGroup from "../../components/CollapsibleGroup";
import { DataType } from "../../enums/DataType";
import InputWithBinding from "../../components/InputWithBinding";
import { localize, GlobalCaption } from "../../components/LocalizationManager";

function getDefaultValue(setting) {
  if (setting.value) return setting.value;

  switch (setting.type) {
    case "plusminus":
      if (setting.minValue) return setting.minValue;
      return 0;

    case "switch":
      return !!setting.value;

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

  if (!setting.caption) {
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
      if (setting.hasOwnProperty("value") && !Number.isInteger(setting.value)) {
        validation.push(
          `Incorrect value type in ${JSON.stringify(
            setting
          )}, integer expected.`
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
        setting.hasOwnProperty("minValue") &&
        !Number.isInteger(setting.minValue)
      ) {
        validation.push(
          `Incorrect minValue type in ${JSON.stringify(
            setting
          )}, integer expected.`
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
      if (
        setting.hasOwnProperty("maxValue") &&
        !Number.isInteger(setting.maxValue)
      ) {
        validation.push(
          `Incorrect maxValue type in ${JSON.stringify(
            setting
          )}, integer expected.`
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

export class DialogConfiguration extends DialogBase {
  constructor(props) {
    super(props);

    this._configuration = this._content.settings.reduce((prev, current) => {
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

  _renderSetting(setting, index, validation) {
    if (!validateSetting(setting, validation)) return null;

    switch (setting.type) {
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
            updater={(value) => this._updateValue(setting.id, value)}
          />
        );
      case "switch":
        return (
          <Switch
            key={index}
            id={setting.id}
            caption={setting.caption}
            value={setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(setting.id, value)}
          />
        );
      case "radio":
        return (
          <RadioGroup
            key={index}
            id={setting.id}
            caption={setting.caption}
            options={setting.options}
            vertical={setting.vertical}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(setting.id, value)}
          />
        );
      case "text":
        return (
          <InputWithBinding
            key={index}
            editable={
              typeof setting.editable === "boolean" ? setting.editable : true
            }
            id={setting.id}
            caption={setting.caption}
            dataType={DataType.STRING}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(setting.id, value)}
          />
        );
      case "integer":
        return (
          <InputWithBinding
            key={index}
            id={setting.id}
            caption={setting.caption}
            dataType={DataType.INTEGER}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(setting.id, value)}
          />
        );
      case "decimal":
        return (
          <InputWithBinding
            key={index}
            id={setting.id}
            caption={setting.caption}
            dataType={DataType.DECIMAL}
            selector={() => setting.value || getDefaultValue(setting)}
            updater={(value) => this._updateValue(setting.id, value)}
          />
        );
      case "group":
        return (
          <CollapsibleGroup
            key={index}
            caption={setting.caption}
            expanded={!!setting.expanded}
          >
            {setting.settings.map((setting, index) => (
              <section key={index}>
                {this._renderSetting(setting, index, validation)}
              </section>
            ))}
          </CollapsibleGroup>
        );
    }
  }

  getBody() {
    const validation = [];
    let settingsVDom = this._content.settings.map((setting, index) => (
      <section key={index}>
        {this._renderSetting(setting, index, validation)}
      </section>
    ));
    if (validation.length) {
      GlobalErrorDispatcher.raiseCriticalError(
        new IncorrectPopupConfigurationError("configuration", validation)
      );
      settingsVDom = "(INVALID CONFIGURATION)";
    }

    return (
      <div
        className={`dialog__settings__body ${
          this._content.vertical ? "dialog__settings__body--vertical" : ""
        }`}
      >
        <div className="dialog__caption">
          <span dangerouslySetInnerHTML={{ __html: this._content.caption }} />
        </div>
        <SimpleBar>{settingsVDom}</SimpleBar>
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
