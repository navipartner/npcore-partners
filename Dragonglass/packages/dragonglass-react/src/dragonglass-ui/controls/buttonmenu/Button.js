import React, { Component } from "react";

export class Button extends Component {
  render() {
    return (
      <div className="c-button c-button--icon c-button--text">
        <div className="c-button__content">
          <span className="c-button__icon fa fa-cog"></span>
          <div className="c-button__caption">
            <span>Icon and text</span>
          </div>
        </div>
      </div>
    );
  }
}
