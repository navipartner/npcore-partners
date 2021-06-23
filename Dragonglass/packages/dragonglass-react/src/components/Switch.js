import React, { Component } from "react";

export default class Switch extends Component {
  constructor(props) {
    super(props);

    this._value = !!this.props.value;
    this.state = {
      generation: 0,
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (nextState.generation !== this.state.generation) return true;

    if (nextProps.value !== this._value) {
      this._value = nextProps.value;
      return true;
    }

    return false;
  }

  _toggleState() {
    this._value = !this._value;
    this.setState({ generation: this.state.generation + 1 });
    if (typeof this.props.updater === "function")
      this.props.updater(this._value);
    if (typeof this.props.onChange === "function")
      this.props.onChange(this._value);
  }

  render() {
    const { caption, id } = this.props;
    const checkboxId = `switch-${id}`;

    return (
      <div className="switch">
        <div className="switch__content">
          <label className="switch__label" htmlFor={checkboxId}>
            <span className="switch__caption">{caption}</span>
            <input
              className="switch__checkbox"
              type="checkbox"
              id={checkboxId}
              checked={!!this._value}
              onChange={() => this._toggleState()}
            />
            <span className="switch__pointer"></span>
          </label>
        </div>
      </div>
    );
  }
}
