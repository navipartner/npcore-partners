import React, { Component } from "react";

/*function getButtonVDom(expanded) {
    return expanded ? <span>(collapse)</span> : <span>V</span>;
}*/

export default class CollapsibleGroup extends Component {
  constructor(props) {
    super(props);

    this.state = {
      expanded: this.props.expanded,
    };
  }

  shouldComponentUpdate(_, nextState) {
    return nextState.expanded !== this.state.expanded;
  }

  _toggleState() {
    this.setState({ expanded: !this.state.expanded });
  }

  render() {
    const { caption, children } = this.props;
    const { expanded } = this.state;

    return (
      <div
        className={`dialog-configuration__group ${
          expanded ? "is-expanded" : "is-collapsed"
        }`}
      >
        <div
          onClick={() => this._toggleState()}
          className="dialog-configuration__group__caption"
        >
          <div className="dialog-configuration__group__caption-container">
            {caption}{" "}
            <span
              className={
                expanded
                  ? "toggle-icon fa-light fa-chevron-down"
                  : "toggle-icon fa-light fa-chevron-up"
              }
            ></span>{" "}
          </div>
        </div>

        <div className="dialog-configuration__group__content">{children}</div>
      </div>
    );
  }
}
