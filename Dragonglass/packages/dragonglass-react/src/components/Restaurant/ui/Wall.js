import React, { Component } from "react";
export class Wall extends Component {
  getStyle() {
    const { component } = this.props;
    const style = {
      width: `${30 * (component.width || 1)}px`,
      height: `${60 * (component.length || 1)}px`,
    };
    if (component.rotation)
      style.transform = `rotate(${component.rotation}deg)`;

    return style;
  }

  render() {
    return <div style={this.getStyle()} className="wall"></div>;
  }
}
