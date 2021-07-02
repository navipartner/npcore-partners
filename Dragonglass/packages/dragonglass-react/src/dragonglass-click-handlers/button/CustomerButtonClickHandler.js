import { ButtonClickHandler } from "./ButtonClickHandler";
import { KnownWorkflows } from "dragonglass-workflows";

export class CustomerButtonClickHandler extends ButtonClickHandler {
    accepts(button) {
        return button.action.Type === "Customer";
    }

    async onClick(button, sender) {
        await KnownWorkflows.customer(button.action);
    }
}
