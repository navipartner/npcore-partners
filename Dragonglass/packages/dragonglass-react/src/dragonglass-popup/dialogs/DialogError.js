import React from "react";
import { DialogBase } from "./DialogBase";

export class DialogError extends DialogBase {
    getBody() {
        return <span dangerouslySetInnerHTML={{ __html: this._content.caption }} />
    }
}
