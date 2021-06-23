import React, { Component } from "react";

export class Panel extends Component {
  render() {
    const { direction } = this.props;
    return (
      <div className={`l-panel ${direction || "l-horizontal"}`}>
        {this.props.children}
      </div>
    );
  }
}
