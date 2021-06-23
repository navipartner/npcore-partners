import React, { Component } from "react";
import { Toolbar } from "./Toolbar";
import { ViewHost } from "./ViewHost";

export class DragonglassPage extends Component {
  render() {
    return (
      <div className="l-vertical l-page">
        <Toolbar />
        <ViewHost />
      </div>
    );
  }
}
