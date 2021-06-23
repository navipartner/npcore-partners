
import { ButtonClickHandler } from "./ButtonClickHandler";
import { ActionType } from "../../enums/ActionType";
import { DO_NOT_RUN_ADDITIONAL_LOGIC } from "../grid/MenuButtonGridClickHandler";

export class BackClickHandler extends ButtonClickHandler {
    accepts(button) {
        return button.action && button.action.Type === ActionType.Back;
    }

    onClick(_, sender) {
        sender.back();
        return DO_NOT_RUN_ADDITIONAL_LOGIC;
    }
}
