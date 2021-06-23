import React, { Component } from "react";

export class Wall extends Component {
  getStyle() {
    const { component } = this.props;
    const style = {
      width: `${1.33 * (component.width || 1)}em`,
      height: `${2 * (component.length || 1)}em`,
    };
    if (component.rotation)
      style.transform = `rotate(${component.rotation}deg)`;

    return style;
  }

  render() {
    return <div style={this.getStyle()} className="wall"></div>;
  }
}
