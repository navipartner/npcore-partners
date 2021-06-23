import React, { Component } from "react";

export class Room extends Component {
  render() {
    return <div className="room">{this.props.caption}</div>;
  }
}
