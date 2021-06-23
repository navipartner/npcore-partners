import { ButtonClickHandler } from "./ButtonClickHandler";
import { KnownWorkflows } from "dragonglass-workflows";
import { SmartTimeoutOperationRunner } from "../../classes/SmartTimeoutOperationRunner";

const runner = new SmartTimeoutOperationRunner(5000);

export class ItemButtonClickHandler extends ButtonClickHandler {
    accepts(button) {
        return button.action.Type === "Item";
    }

    async onClick(button, sender) {
        const action = { ...button.action };
        if (button._additionalContext) {
            action._additionalContext = button._additionalContext;
        }

        // TODO: Optimize this to not completely exclude this, but to show a pending line after a little timeout (e.g. 50 ms) - this would allow near-instant representation of new line, and pending to be shown only if really slow
        // const newLine = DataManager.insertItemWithPending(action.Code, button.caption, sender.props.layout.dataSource);
        // await runner.start(async () => await KnownWorkflows.item(action));
        // DataManager.cancelPendingLineIfNecessary(newLine);
        await KnownWorkflows.item(action);
    }
}
