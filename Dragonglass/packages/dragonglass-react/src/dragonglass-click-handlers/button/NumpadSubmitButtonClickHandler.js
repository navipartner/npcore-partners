import { ButtonClickHandler } from "./ButtonClickHandler";
import Input from "../../components/Input";

export class NumpadSubmitButtonClickHandler extends ButtonClickHandler {
    constructor(submitFunction) {
        super();
        this._submitFunction = submitFunction;
    }

    accepts(button) {
        return button.submit;
    }

    onClick() {
        if (typeof this._submitFunction !== "function")
            return false;

        this._submitFunction();
        return true;
    }
}