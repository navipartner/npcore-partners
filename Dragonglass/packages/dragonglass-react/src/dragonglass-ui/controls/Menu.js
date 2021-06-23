import React, { Component } from "react";
import { MenuIndicator } from "./MenuIndicator";

let elementNextId = 1;

export class Menu extends Component {
  constructor(props) {
    super(props);
    this.state = {
      active: "login",
    };
  }

  _activate(item) {
    if (this.state.active === item) return;

    this.setState({ active: item });
  }

  render() {
    const uniqueClass = `selectedMenu${elementNextId++}`;
    return (
      <>
        <div
          onClick={() => this._activate("login")}
          className={`c-navigation__item ${
            this.state.active === "login" ? `is-active ${uniqueClass}` : ""
          }`}
        >
          Login
        </div>
        <div
          onClick={() => this._activate("sale")}
          className={`c-navigation__item ${
            this.state.active === "sale" ? `is-active ${uniqueClass}` : ""
          }`}
        >
          Sale
        </div>
        <div
          onClick={() => this._activate("payment")}
          className={`c-navigation__item ${
            this.state.active === "payment" ? `is-active ${uniqueClass}` : ""
          }`}
        >
          Payment
        </div>
        <MenuIndicator uniqueClass={uniqueClass} />
      </>
    );
  }
}
