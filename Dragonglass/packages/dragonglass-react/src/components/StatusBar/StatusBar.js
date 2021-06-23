import React, { Component } from "react";
import { populateSections } from "./statusBarHelper";
import { bindComponentToViewLayoutState } from "../../redux/view/view-bind";
import { StatusBarNotifications } from "./StatusBarNotifications";

class StatusBar extends Component {
  render() {
    const { tag, layout } = this.props;
    const { statusBar } = layout;
    const id = `statusbar-${tag}`;
    return statusBar ? (
      <div id={id} className="statusbar">
        <>{populateSections.call(this, statusBar, id, statusBar.dataSource)}</>

        {/* TODO: Fix this! It negatively affects speed. Use profiler! */}
        <StatusBarNotifications />
      </div>
    ) : null;
  }
}

export default bindComponentToViewLayoutState(StatusBar);
