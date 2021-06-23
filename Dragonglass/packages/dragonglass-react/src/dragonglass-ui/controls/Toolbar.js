import React, { Component } from "react";
import { Menu } from "./Menu";

export class Toolbar extends Component {
  render() {
    return (
      <div className="c-navbar">
        <div className="c-logo">NP Retail 2017</div>
        <div className="c-navigation c-navigation--main-menu">
          <Menu />
        </div>
      </div>
    );
  }
}
