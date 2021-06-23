import React from "react";
import { DialogBase } from "../DialogBase";
import { DialogButtons } from "../DialogButtons";
import { SeatingFloor } from "./SeatingFloor";
import { SeatingSetupMenu } from "./setup/SeatingSetupMenu";
import {
  seatingGetNextId,
  seatingGetNextCaption,
  seatingTypeTitle,
} from "./setup/SeatingSetupFunctions";
import { Popup } from "../../PopupHost";
import {
  localize,
  GlobalCaption,
} from "../../../components/LocalizationManager";

export class DialogSeatingSetup extends DialogBase {
  constructor(props) {
    super(props);

    const layout =
      typeof props.content.layout === "object" ? props.content.layout : {};
    const location =
      typeof props.content.location === "string"
        ? props.content.location
        : null;
    if (!Array.isArray(layout.components)) layout.components = [];
    if (!Array.isArray(layout.locations)) layout.locations = [];

    this.state = { layout };
    if (location) this.state.location = location;
  }

  accept() {
    this._interface.close({ ...this.state.layout });
  }

  dismiss() {
    this._interface.close(null);
  }

  _menu(context) {
    switch (context.action) {
      case "new":
        const id = seatingGetNextId(
          this.state.layout.components,
          "",
          context.type
        ); // `${context.type.toUpperCase()}-${this._getNewId(context.type)}`;
        const caption = seatingGetNextCaption(
          this.state.layout.components,
          seatingTypeTitle(context.type)
        );
        const components = [
          ...this.state.layout.components,
          {
            type: context.type,
            id: id,
            caption: caption,
            location: this.state.location,
          },
        ];
        const layout = { ...this.state.layout, components };
        this.setState({ layout });
        break;
      case "location":
        switch (context.type) {
          case "new":
          case "edit":
            Popup.configuration({
              title: "New Location",
              settings: [
                {
                  type: "text",
                  id: "id",
                  caption: "Id",
                  value: context.target ? context.target.id : "",
                },
                {
                  type: "text",
                  id: "caption",
                  caption: "Caption",
                  value: context.target ? context.target.caption : "",
                },
              ],
            }).then((result) => {
              if (!result) return;

              const locations = [...this.state.layout.locations];
              if (context.target) {
                const location = locations.find(
                  (l) => l.id == context.target.id
                );
                location.id = result.id;
                location.caption = result.caption;
              } else {
                locations.push({
                  id: "",
                  caption: result.caption,
                  id: result.id,
                });
              }
              const layout = { ...this.state.layout, locations };
              this.setState({ layout, location: result.id });
            });
            break;
          case "delete":
            const locations = [
              ...this.state.layout.locations.filter(
                (l) => l.id !== context.target
              ),
            ];
            const layout = { ...this.state.layout, locations };
            const location = locations.length
              ? locations[locations.length - 1].id
              : undefined;
            this.setState({ layout, location });
            break;
          case "select":
            this.setState({ location: context.target });
            break;
        }
        break;
    }
  }

  _contextMenu(context) {
    switch (context.action) {
      case "remove":
    }
  }

  getBody() {
    return (
      <div className="seating-container">
        <SeatingSetupMenu
          layout={this.state.layout}
          location={this.state.location}
          action={(context) => this._menu(context)}
        />
        <SeatingFloor
          layout={this.state.layout}
          location={this.state.location}
          update={(layout) => this.setState({ layout })}
        />
      </div>
    );
  }

  getButtons() {
    return (
      <DialogButtons
        buttons={[
          {
            id: "button-dialog-yes",
            caption: localize(GlobalCaption.FromBackEnd.Global_Yes),
            click: this.accept.bind(this),
          },
          {
            id: "button-dialog-no",
            caption: localize(GlobalCaption.FromBackEnd.Global_No),
            click: this.dismiss.bind(this),
          },
        ]}
      />
    );
  }
}
