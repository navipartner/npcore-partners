import React, { Component } from "react";
import Button from "./Button";
import { GridClickHandler } from "../dragonglass-click-handlers/grid/GridClickHandler";
import { GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { buildClass, isMobile } from "../classes/functions";
import { ButtonGridPluginRepository } from "./ButtonGridPluginRepository";
import { bindComponentToMenuState } from "../redux/menu/menu-selectors";

function calculateHeights(layout, popup) {
  if (!layout || popup) return [];

  let factors = layout.rows || [];
  if (!Array.isArray(layout.rows))
    if (typeof layout.rows === "number") factors = Array(layout.rows).fill(1);

  const sumFactors = factors.reduce((prev, cur) => prev + cur);
  const heights = factors.map((factor) => 100 * (factor / sumFactors));
  return heights;
}

function transformButtons(buttons, popup) {
  if (!popup || !isMobile()) return buttons;

  const oneRow = [];
  buttons.forEach((row) => row.forEach((button) => oneRow.push(button)));
  return [oneRow];
}

class ButtonGrid extends Component {
  constructor(props) {
    super(props);

    this.state = {
      menu: null,
      enabled: true,
    };
    this._menuStack = [];
    this._boundPlugins = [];

    this._transactionStart = () => {
      this._menuStack = [];
      this.setState({ menu: null });
    };
  }

  componentDidMount() {
    const { layout } = this.props;
    if (layout && layout.plugins && layout.plugins.length !== 0) {
      for (let id of layout.plugins) {
        let plugin = ButtonGridPluginRepository.get(id);
        if (plugin) {
          plugin.bindGrid(this);
          this._boundPlugins.push(plugin);
        }
      }
    }

    GlobalEventDispatcher.addEventListener(
      GLOBAL_EVENTS.TRANSACTION_START,
      this._transactionStart
    );
  }

  componentWillUnmount() {
    for (let plugin of this._boundPlugins) {
      plugin.unbindGrid(this);
    }

    GlobalEventDispatcher.removeEventListener(
      GLOBAL_EVENTS.TRANSACTION_START,
      this._transactionStart
    );
  }

  _click(e) {
    const { clickHandler } = this.props;
    const { button } = e;

    if (clickHandler && clickHandler instanceof GridClickHandler) {
      if (clickHandler.onClick(button, this)) return;
    }

    const { onClick } = this.props;
    typeof onClick === "function" && onClick(e);
  }

  set enabled(enabled) {
    if (enabled === this.state.enabled) return;

    this.setState({ enabled });
  }

  get enabled() {
    return this.state.enabled;
  }

  /**
   * Sets new array of buttons to display in this ButtonGrid.
   *
   * @param {Array<Array<MenuButtonInfo>>} buttons Grid of MenuButtonInfo instances that define the menu to show in this button grid
   */
  setButtons(menu) {
    this._menuStack.push(this.state.menu || this.props.menu);
    this.setState({ menu: menu });
  }

  back() {
    const menu = this._menuStack.pop();
    if (!menu || !menu.length) return;

    this.setState({ menu: menu });
  }

  render() {
    const { id, layout, defaultLayoutOptions, popup } = this.props;

    let rowId = 0;
    let buttonId = 0;
    const buttons = transformButtons(
      this.props.buttons || this.state.menu || this.props.menu,
      popup
    );
    let rows = calculateHeights(layout, popup);

    return (
      <div
        className={buildClass("buttongrid", popup && "buttongrid--popup")}
        id={id}
      >
        {buttons &&
          buttons.map((row, index) => {
            const divProps = {
              key: rowId++,
              className: "buttongrid__row",
            };
            if (rows.length) {
              divProps.style = {
                flexGrow: 1,
                flexShrink: 1,
                flexBasis: index < rows.length ? `${rows[index]}%` : "auto",
              };
            }

            const buttonProps = {
              className: "button",
            };
            if (layout && layout.dataSource) {
              buttonProps.dataSourceName = layout.dataSource;
            }

            return (
              <div {...divProps}>
                {row.map((button) => {
                  let actualButtonProps = buttonProps;
                  if (
                    button &&
                    button.action &&
                    button.action.Content &&
                    button.action.Content.dataSource
                  ) {
                    actualButtonProps = { ...buttonProps };
                    actualButtonProps.dataSourceName =
                      button.action.Content.dataSource;
                  }

                  return (
                    <Button
                      defaultLayoutOptions={defaultLayoutOptions}
                      defaultEnabled={this.state.enabled}
                      grid={this}
                      key={buttonId++}
                      button={button}
                      {...actualButtonProps}
                      onClick={(e) => this._click(e)}
                    ></Button>
                  );
                })}
              </div>
            );
          })}
      </div>
    );
  }
}

export default bindComponentToMenuState(ButtonGrid);
