import React, { Component } from "react";

export class View extends Component {
  render() {
    return (
      <div className="l-view l-horizontal l-view--sale">
        {this.props.children}
      </div>
    );
  }
}
