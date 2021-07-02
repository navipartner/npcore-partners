import { GenericGridClickHandler } from "./GenericGridClickHandler";
import { SubmenuClickHandler } from "../button/SubmenuClickHandler";
import { BackClickHandler } from "../button/BackClickHandler";
import { WorkflowButtonClickHandler } from "../button/WorkflowButtonClickHandler";
import { ItemButtonClickHandler } from "../button/ItemButtonClickHandler";
import { PopupMenuButtonClickHandler } from "../button/PopupMenuButtonClickHandler";
import { PaymentButtonClickHandler } from "../button/PaymentButtonClickHandler";
import { CustomerButtonClickHandler } from "../button/CustomerButtonClickHandler";

export const DO_NOT_RUN_ADDITIONAL_LOGIC = Symbol("DO_NOT_RUN_ADDITIONAL_LOGIC");

export class MenuButtonGridClickHandler extends GenericGridClickHandler {
    constructor(additionalClickLogic) {
        super();

        if (typeof additionalClickLogic === "function")
            this._additionalClickLogic = additionalClickLogic;

        this.registerClickHandler(new SubmenuClickHandler());
        this.registerClickHandler(new BackClickHandler());
        this.registerClickHandler(new WorkflowButtonClickHandler());
        this.registerClickHandler(new ItemButtonClickHandler());
        this.registerClickHandler(new PopupMenuButtonClickHandler());
        this.registerClickHandler(new PaymentButtonClickHandler());
        this.registerClickHandler(new CustomerButtonClickHandler());
    }

    onClick(button, sender) {
        // if (super.onClick(button, sender) === DO_NOT_RUN_ADDITIONAL_LOGIC && this._additionalClickLogic)
        //     this._additionalClickLogic();
        var result = super.onClick(button, sender);
        if (result !== DO_NOT_RUN_ADDITIONAL_LOGIC && this._additionalClickLogic) {
            this._additionalClickLogic();
            return true;
        }

        return result;
    }
}
