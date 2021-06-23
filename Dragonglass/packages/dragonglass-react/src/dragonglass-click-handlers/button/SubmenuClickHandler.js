
import { ButtonClickHandler } from "./ButtonClickHandler";
import { ActionType } from "../../enums/ActionType";
import { DO_NOT_RUN_ADDITIONAL_LOGIC } from "../grid/MenuButtonGridClickHandler";

/**
 * Represents a button click handler for submenu buttons.
 */
export class SubmenuClickHandler extends ButtonClickHandler {
    accepts(button) {
        return button &&
            button.action &&
            button.action.Type === ActionType.SubMenu &&
            Array.isArray(button.submenu) &&
            button.submenu.length;
    }

    /**
     * Responds to the click event when a submenu button was clicked in a ButtonGrid.
     * 
     * @param {Button} button Button that was clicked
     * @param {ButtonGrid} sender ButtonGrid to which the clicked button belongs
     */
    onClick(button, sender) {
        sender.setButtons(button.submenu);
        return DO_NOT_RUN_ADDITIONAL_LOGIC;
    }
}
