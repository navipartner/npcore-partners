import React from "react";
import { SeatingComponent } from "./SeatingComponent";
import Table from "../../../components/Restaurant/ui/Table";
import { Popup } from "../../PopupHost";

export class SeatingTable extends SeatingComponent {
    _edit(layout, update) {
        const { component } = this.props;

        Popup.configuration({
            title: `Configure ${component.caption}`,
            settings: [
                {
                    id: "chairs",
                    type: "group",
                    caption: "Chairs",
                    expanded: true,
                    settings: [
                        { type: "integer", caption: "Count", id: "count", value: component.chairs && component.chairs.count || 0 },
                        { type: "integer", caption: "Minimum", id: "min", value: component.chairs && component.chairs.min || 0 },
                        { type: "integer", caption: "Maximum", id: "max", value: component.chairs && component.chairs.max || 0 },
                    ]
                },
                {
                    id: "round",
                    type: "switch",
                    caption: "Round",
                    value: !!component.round
                },
                {
                    id: "size",
                    type: "group",
                    caption: "Size",
                    expanded: true,
                    settings: [
                        { type: "integer", caption: "Width", id: "width", value: component.width || 1 },
                        { type: "integer", caption: "Height", id: "height", value: component.height || 1 }
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
                chairs: {
                    count: result.count,
                    min: result.min,
                    max: result.max
                },
                capacity: result.count,
                round: result.round,
                width: result.width,
                height: result.height,
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
            <Table component={this.props.component} />
        );
    }
}
