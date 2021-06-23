import React, { Component } from "react";
import View from "./View.js";
import StatusBar from "./StatusBar/StatusBar";
import { bindComponentToViewActiveState } from "../redux/view/view-bind.js";
import { focusAvailableInput } from "./FocusManager.js";

class Page extends Component {
  render() {
    const { tag, active } = this.props;

    active && setTimeout(focusAvailableInput);

    return tag ? (
      <div
        id={`page-${tag}`}
        className={`page ${tag}`}
        style={{ display: active ? undefined : "none" }}
      >
        <View tag={tag} active={active}></View>
        <StatusBar tag={tag}></StatusBar>
      </div>
    ) : (
      <></>
    );
  }
}

export default bindComponentToViewActiveState(Page);
