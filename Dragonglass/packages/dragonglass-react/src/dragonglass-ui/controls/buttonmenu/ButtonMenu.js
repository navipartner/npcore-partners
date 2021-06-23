import React, { Component } from "react";
import { Menu } from "../Menu";
import { ButtonMenuContent } from "./ButtonMenuContent";

export class ButtonMenu extends Component {
  render() {
    return (
      <div className="c-button-menu l-vertical">
        <div className="c-navigation c-navigation--button-menu">
          <Menu />
        </div>
        <ButtonMenuContent />
      </div>
    );
  }
}
