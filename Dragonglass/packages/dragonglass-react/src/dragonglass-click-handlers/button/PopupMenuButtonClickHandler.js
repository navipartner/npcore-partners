
import { ButtonClickHandler } from "./ButtonClickHandler";
import { ActionType } from "../../enums/ActionType";
import { Popup } from "../../dragonglass-popup/PopupHost";
import { StateStore } from "../../redux/StateStore";

export class PopupMenuButtonClickHandler extends ButtonClickHandler {
    accepts(button) {
        return button.action && button.action.Type === ActionType.PopupMenu;
    }

    onClick(button, sender) {
        const state = StateStore.getState().menu || {};
        const menu = state[button.action.MenuId] || {}
        const params = button.action.Parameters || {};
        const caption = menu.Caption || button.caption || "";
        Popup.menu({
            title: caption,
            source: button.action.MenuId,
            columns: params.Columns || 5,
            rows: params.Rows || 6,
            dataSource: sender.props.layout && sender.props.layout.dataSource
        });

        return true;
    }
}
