import React, { PureComponent } from "react";
import { bindComponentToViewLayoutState } from "../redux/view/view-bind";
import { Workflow } from "dragonglass-workflows";
import { View as Mobile } from "./renderers/mobile/View";
import { Classic } from "./renderers/classic/classic";

const UI = ({ tag, layout }) => {
  switch (layout.renderer) {
    case "mobile":
      return <Mobile tag={tag} layout={layout} />;

    case undefined:
      return <Classic tag={tag} layout={layout} />;
  }
};

class View extends PureComponent {
  render() {
    const { tag, active, layout } = this.props;

    if (active) {
      Workflow.definePerViewWorkflowSetup(layout.workflows || {}, tag);
    }

    return <UI tag={tag} layout={layout} />;
  }
}

export default bindComponentToViewLayoutState(View);
