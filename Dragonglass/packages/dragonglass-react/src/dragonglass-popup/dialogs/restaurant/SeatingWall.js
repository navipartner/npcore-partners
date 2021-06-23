import React from "react";
import { SeatingComponent } from "./SeatingComponent";
import { Wall } from "../../../components/Restaurant/ui/Wall";
import { Popup } from "../../PopupHost";

export class SeatingWall extends SeatingComponent {
    _edit(layout, update) {
        const { component } = this.props;

        Popup.configuration({
            title: `Configure ${component.caption}`,
            settings: [
                {
                    id: "size",
                    type: "group",
                    caption: "Size",
                    expanded: true,
                    settings: [
                        { type: "integer", caption: "Width", id: "width", value: component.width || 1 },
                        { type: "integer", caption: "Length", id: "length", value: component.length || 1 }
                    ]
                },
                {
                    id: "rotation",
                    type: "integer",
                    caption: "Rotation (degrees)",
                    value: component.rotation || 0
                }
            ]
        }).then(result => {
            const newComponent = {
                ...component,
                width: result.width,
                length: result.length,
                rotation: result.rotation
            };
            const components = [...layout.components.filter(c => c !== component), newComponent];
            update({ ...layout, components });
        });
    }

    getOptions() {
        var { update, component } = this.props;

        return [
            {
                icon: "",
                caption: "Configure",
                onClick: () => update(component, (layout, update) => this._edit(layout, update))
            }
        ]
    }

    getContent() {
        return (
            <Wall component={this.props.component} />
        );
    }
}
