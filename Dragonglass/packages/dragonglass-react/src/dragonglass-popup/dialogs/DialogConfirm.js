import React from "react";
import { DialogBase } from "./DialogBase";
import { DialogButtons } from "./DialogButtons";
import { localize, GlobalCaption } from "../../components/LocalizationManager";

export class DialogConfirm extends DialogBase {
    constructor(props) {
        super(props);
        this._confirmOnEnter = this._content.hasOwnProperty("confirmOnEnter") ? !!this._content.confirmOnEnter : true;
    }

    accept() {
        this._interface.close(true);
    }

    dismiss() {
        this._interface.close(false);
    }

    canAcceptWithEnterKeyPress() {
        return this._confirmOnEnter;
    }

    canDismissByClickingOutside() {
        return false;
    }

    getBody() {
        return <span dangerouslySetInnerHTML={{ __html: this._content.caption }} />
    }

    getButtons() {
        return <DialogButtons
            buttons={[
                { id: "button-dialog-yes", caption: localize(GlobalCaption.FromBackEnd.Global_Yes), click: this.accept.bind(this) },
                { id: "button-dialog-no", caption: localize(GlobalCaption.FromBackEnd.Global_No), click: this.dismiss.bind(this) }
            ]}
        />
    }
}
