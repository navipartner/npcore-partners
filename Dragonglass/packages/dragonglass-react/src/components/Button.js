import React, { Component } from "react";
import Caption from "./Caption";
import { buildClass } from "../classes/functions";
import { MenuButtonInfo } from "../classes/ButtonGridMenuBuilder";
import { bindComponentToDataSetAutoEnableState } from "../redux/reducers/dataReducer";
import Image from "./Image";
import { Workflow } from "dragonglass-workflows";
import { GlobalEventDispatcher } from "dragonglass-core";

let buttonId = 0;

function caption(props) {
  const button = props.button || {};
  return button && button.hasOwnProperty("caption")
    ? button.caption
    : props.caption;
}

const ButtonCaption = (props) => {
  function additional() {
    return props.dataSourceName ? { dataSourceName: props.dataSourceName } : {};
  }

  return (
    <span className="button__caption">
      <Caption caption={caption(props)} {...additional()}></Caption>
    </span>
  );
};

const ButtonIcon = (props) => {
  const button = props.button || {};
  return button.iconClass ? (
    <span
      className={buildClass(
        "button__icon",
        "button__icon--size-32",
        button.iconClass
      )}
    />
  ) : null;
};

const translateImageProperty = (image) => {
  switch (typeof image) {
    case "object":
      let result = { BackgroundImageUrl: image.url };
      switch (image.position) {
        case "top":
          result.CaptionPosition = 2;
          break;
        case "bottom":
          result.CaptionPosition = 1;
          break;
        case "icon":
          result = { iconImage: image.url };
          break;
      }
      return result;
    case "string":
      return { BackgroundImageUrl: image };
  }
  return {};
};

const defineStyle = (object, style) => {
  if (!object.style) object.style = {};
  object.style = { ...object.style, ...style };
};

const translateJsonPropsToButtonContent = (button, layout) => {
  if (button.content) return button.content;

  let content = { additional: {} };
  if (layout) {
    if (layout.image) {
      content = { ...content, ...translateImageProperty(layout.image) };
    }
    if (layout.width) {
      defineStyle(content.additional, {
        width: layout.width,
        flex: "initial",
      });
    }
    if (layout.height) {
      defineStyle(content.additional, {
        height: layout.height,
      });
    }
    if (layout.icon) {
      content.icon = layout.icon;
    }
  }

  return content;
};

const getButtonProps = (props, enabled, defaultLayoutOptions) => {
  const { id, selected } = props;
  const button = props.button || {};
  const buttonColor =
    button.backgroundColor && `button--color-${button.backgroundColor}`;

  let captionPosition = null;
  const content = translateJsonPropsToButtonContent(button, props.layout);
  const innerWrapperStyle = {};
  if (content) {
    if (content.BackgroundImageUrl) {
      innerWrapperStyle.style = {
        background: `url(${content.BackgroundImageUrl}) no-repeat 0 0 / 100% auto`,
      };
      switch (content.CaptionPosition) {
        case 1:
          captionPosition = "button--image-below";
          break;
        case 2:
          captionPosition = "button--image-above";
      }
    }
  }

  const showPlusMinus =
    props.button &&
    props.button.action &&
    props.button.action.Content &&
    props.button.action.Content.ShowPlusMinus;

  return {
    outerWrapperAttributes: {
      className: buildClass(
        "button",
        buttonColor,
        selected && "button--selected",
        !enabled && "button--disabled",
        button.iconClass && "button--has-icon",
        button.class || "",
        showPlusMinus && "button--has-plus-minus",
        captionPosition,
        props.additionalClassNames,
        defaultLayoutOptions &&
          defaultLayoutOptions.button &&
          defaultLayoutOptions.button.class
      ),
      ...content.additional,
      id: id || `button${++buttonId}`,
    },
    innerWrapperAttributes: {
      className: buildClass(
        !enabled && "button--disabled",
        buttonColor,
        selected && "button--selected"
      ),
      ...innerWrapperStyle,
    },
    iconImage: content.iconImage,
    icon: content.icon,
    showPlusMinus,
  };
};

const runWorkflow = (action) => {
  const context = {};
  if (action.parameters) {
    context.parameters = action.parameters;
  }

  Workflow.run(action.action, context);
};

const PlusMinusButton = (props) => {
  const { showPlusMinus, onClick, caption, className } = props;
  return showPlusMinus ? (
    <div
      className={className}
      onClick={(e) => {
        onClick(e);
        e.stopPropagation();
      }}
    >
      {caption}
    </div>
  ) : null;
};

class Button extends Component {
  constructor(props) {
    super(props);

    if (!(this.props.button instanceof MenuButtonInfo)) {
      this.state = {
        enabled: true,
      };
    }
  }
  _click(e, plusMinus, qty) {
    if (!this._enabled) {
      console.info(`Ignoring click on disabled button`);
      return;
    }

    GlobalEventDispatcher.buttonClick({
      button: this.props.button,
      caption: caption(this.props),
    });

    if (this.props.action) {
      runWorkflow(this.props.action);
      return;
    }

    const { onClick, button } = this.props;
    const param = { originalEvent: e, button: button };
    if (plusMinus)
      param.button = {
        ...button,
        _additionalContext: { plusMinus: true, quantity: qty },
      };
    typeof onClick === "function" && onClick(param);
  }

  get _enabled() {
    if (typeof this.props.enabled === "boolean") return this.props.enabled;

    const defaultEnabled =
      typeof this.props.defaultEnabled === "boolean"
        ? this.props.defaultEnabled
        : true;

    return (
      defaultEnabled &&
      (this.state && this.state.hasOwnProperty("enabled")
        ? this.state.enabled
        : !!(this.props.button && this.props.button.enabled))
    );
  }

  render() {
    const { defaultLayoutOptions } = this.props;
    const buttonProps = getButtonProps(
      this.props,
      this._enabled,
      defaultLayoutOptions
    );
    const iconProps = { ...this.props };
    if (buttonProps.icon) iconProps.button = { iconClass: buttonProps.icon };

    return (
      <div
        {...buttonProps.outerWrapperAttributes}
        onClick={(e) => this._click(e)}
      >
        <div {...buttonProps.innerWrapperAttributes}>
          <PlusMinusButton
            className="button__plus-minus button--minus"
            showPlusMinus={buttonProps.showPlusMinus}
            caption="-"
            onClick={(e) => this._click(e, true, -1)}
          />
          {buttonProps.iconImage ? (
            <Image src={buttonProps.iconImage}></Image>
          ) : null}
          <ButtonIcon {...iconProps} />
          <ButtonCaption {...this.props} />
          <PlusMinusButton
            className="button__plus-minus button--plus"
            showPlusMinus={buttonProps.showPlusMinus}
            caption="+"
            onClick={(e) => this._click(e, true, 1)}
          />
        </div>
      </div>
    );
  }
}

export default bindComponentToDataSetAutoEnableState(Button);
