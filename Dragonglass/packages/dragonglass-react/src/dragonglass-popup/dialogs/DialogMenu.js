import React from "react";
import ButtonGrid from "../../components/ButtonGrid";
import { MenuButtonGridClickHandler } from "../../dragonglass-click-handlers/grid/MenuButtonGridClickHandler";
import { DialogBase } from "./DialogBase";

export class DialogMenu extends DialogBase {
  getBody() {
    return (
      <ButtonGrid
        clickHandler={new MenuButtonGridClickHandler(() => this.accept())}
        id={`dialog-menu-${this._content.source}`}
        layout={this._content}
        popup={true}
      />
    );
  }
}
