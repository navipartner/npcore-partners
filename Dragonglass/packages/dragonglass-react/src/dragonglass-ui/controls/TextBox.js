import React, { Component } from "react";
import { Button } from "./buttonmenu/Button";

export class TextBox extends Component {
  constructor(props) {
    super(props);
    this.state = {
      active: false,
      open: false,
    };
    this._refs = {};
  }

  render() {
    const { active, open } = this.state;
    return (
      <div
        className={
          open
            ? "c-textbox c-textbox--item-lookup l-vertical is-active"
            : "c-textbox c-textbox--item-lookup l-vertical"
        }
      >
        <div className="c-textbox__button-menu">
          <div className="c-grid c-grid--button-menu">
            <div className="c-grid__row c-grid__row--button-menu">
              <Button />
              <Button />
              <Button />
              <Button />
              <Button />
            </div>
          </div>
        </div>

        <div
          className={
            active ? "c-textbox__content is-active" : "c-textbox__content"
          }
        >
          <label className="c-textbox__label">{this.props.label}</label>
          <input
            className="c-textbox__input"
            ref={(input) => (this._refs.input = input)}
            type="text"
            onFocus={() => this.setState({ active: true })}
            onBlur={() =>
              this._refs.input.value || this.setState({ active: false })
            }
            autoComplete="off"
          />
          <div className="c-button c-button--reset c-button--textbox">
            <div
              className="c-button__content c-button__content--textbox c-button__content--reset"
              onClick={() => {
                this._refs.input.value = "";
                this._refs.input.focus();
              }}
            >
              <span className="c-button__icon c-button__icon--reset fa fa-times"></span>
            </div>
          </div>
          <div
            onClick={() => this.setState({ open: !this.state.open })}
            className="c-button c-button--search c-button--textbox"
          >
            <div className="c-button__content c-button__content--textbox c-button__content--search">
              <span className="c-button__icon c-button__icon--search fa fa-search"></span>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
