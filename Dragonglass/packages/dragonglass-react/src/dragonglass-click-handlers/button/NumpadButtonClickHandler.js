import { ButtonClickHandler } from "./ButtonClickHandler";
import { IncorrectSignatureError } from "../../dragonglass-errors/IncorrectSignatureError";

export class NumpadButtonClickHandler extends ButtonClickHandler {
    constructor(enterValueFunction) {
        super();
        if (typeof enterValueFunction !== "function")
            throw new IncorrectSignatureError("The enterValueFunction parameter must be of type 'function'.");

        this._enterValueFunction = enterValueFunction;
    }

    accepts(button) {
        return !button.submit && (button.hasOwnProperty("caption") || button.value);
    }

    onClick(button) {
        this._enterValueFunction(button.hasOwnProperty("value") ? button.value : button.caption);
        return true;
    }
}
