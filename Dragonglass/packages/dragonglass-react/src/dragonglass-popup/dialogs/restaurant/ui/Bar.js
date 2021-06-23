import React, { Component } from "react";

export class Bar extends Component {
  getStyle() {
    const { component } = this.props;
    const style = {};
    if (component.rotation)
      style.transform = `rotate(${component.rotation}deg)`;

    return style;
  }
  render() {
    const { component } = this.props;
    return (
      <div style={this.getStyle()} className="bar">
        {component.caption}
      </div>
    );
  }
}
