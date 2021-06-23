import React from "react";
import { DialogBase } from "./DialogBase";
import { DialogStyleProvider } from "../DialogStyleProvider";
import { DialogButtons } from "./DialogButtons";
import { localize, GlobalCaption } from "../../components/LocalizationManager";
import Caption from "../../components/Caption";
//import "../../styles/dragonglass-ui/components/dialog/DialogTimeout.scss"; // dragonglass

export class DialogTimeout extends DialogBase {
  constructor(props) {
    super(props);

    this._timeout = this._content.timeout || 15;
    setTimeout(() => this.accept(), this._timeout * 1000);
  }

  getBody() {
    return <Caption caption={this._content.caption} />;
  }

  getButtons() {
    return (
      <DialogButtons
        buttons={[
          {
            id: "button-dialog-ok",
            caption:
              this._content.buttonCaption ||
              localize(GlobalCaption.FromBackEnd.Global_OK),
            click: this.dismiss.bind(this),
          },
        ]}
      />
    );
  }

  getCustomStyleProvider() {
    return new DialogStyleProvider({
      bodyStyle: {
        animationDuration: `${this._timeout || 15}s`,
      },
    });
  }
}
