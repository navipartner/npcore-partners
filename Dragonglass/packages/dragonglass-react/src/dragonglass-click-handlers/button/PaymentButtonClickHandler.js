import { ButtonClickHandler } from "./ButtonClickHandler";
import { KnownWorkflows } from "dragonglass-workflows";

export class PaymentButtonClickHandler extends ButtonClickHandler {
    accepts(button) {
        return button.action.Type === "Payment";
    }

    async onClick(button, sender) {
        // TODO: maybe perform the same kind of pending line concept as with items
        await KnownWorkflows.payment(button.action);
    }
}
