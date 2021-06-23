import React from "react";
import { SeatingComponent } from "./SeatingComponent";
import { Bar } from "../../../components/Restaurant/ui/Bar";
import { Popup } from "../../PopupHost";

export class SeatingBar extends SeatingComponent {
    _edit(layout, update) {
        const { component } = this.props;

        Popup.configuration({
            title: `Configure ${component.caption}`,
            settings: [
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
            <Bar component={this.props.component} />
        );
    }
}
