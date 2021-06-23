import { ButtonClickHandler } from "./ButtonClickHandler";
import { Workflow } from "dragonglass-workflows";
import { Globals } from "../../Globals.REFACTOR";

export class WorkflowButtonClickHandler extends ButtonClickHandler {
  accepts(button) {
    return (
      button.action &&
      button.action.Type === "Workflow" &&
      button.action.Workflow
    );
  }

  onClick(button, sender) {
    let action;
    switch (button.action.Workflow.Content.engineVersion) {
      case undefined:
        action = Globals.transcendence.getNewButtonWorkflow(button);
        break;
      case "2.0":
        if (
          sender &&
          Array.isArray(sender.props.layout && sender.props.layout.plugins)
        ) {
          button.plugins = sender.props.layout.plugins;
        }
        action = new Workflow(button);
        break;
    }
    action.source = button;
    action.grid = button.parentGrid;
    Globals.transcendence.actionActive(true);
    action.execute(
      sender && sender.props.layout && sender.props.layout.dataSource,
      () => Globals.transcendence.actionActive(false)
    );
  }
}
