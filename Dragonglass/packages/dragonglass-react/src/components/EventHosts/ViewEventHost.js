import React, { Component } from "react";
import { bindComponentToViewState } from "../../redux/view/view-bind";

class ViewEventHost extends Component {
  componentDidUpdate(prevProps) {
    const { eventHandlers } = this.props;
    if (!eventHandlers) return;

    if (
      eventHandlers.onChangeActiveView &&
      this.props.view.active !== prevProps.view.active
    )
      eventHandlers.onChangeActiveView(
        this.props.view.active,
        prevProps.view.active
      );
  }

  render() {
    return <></>;
  }
}

export default bindComponentToViewState(ViewEventHost);
