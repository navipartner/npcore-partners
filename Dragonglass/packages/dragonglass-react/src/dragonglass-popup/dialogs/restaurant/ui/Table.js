import React, { Component } from "react";
import { Chair } from "./Chair";

export class Table extends Component {
  getStyle() {
    const { component } = this.props;
    const style = {
      width: `${4 * (component.width || 1)}em`,
      height: `${4 * (component.height || 1)}em`,
    };
    if (component.rotation)
      style.transform = `rotate(${component.rotation}deg)`;

    return style;
  }

  render() {
    const { component } = this.props;
    return (
      <div
        style={this.getStyle()}
        className={`table${component.round ? " table--round" : ""}`}
      >
        {component.caption}
        <Chair chairs={(component.chairs && component.chairs.count) || 0} />
      </div>
    );
  }
}
