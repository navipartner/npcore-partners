import React, { Component } from "react";
import { SeatingBar } from "./SeatingBar";
import { SeatingDoor } from "./SeatingDoor";
import { SeatingRoom } from "./SeatingRoom";
import { SeatingTable } from "./SeatingTable";
import { SeatingWall } from "./SeatingWall";
import { SEATING_COMPONENT_DUPLICATE, SEATING_COMPONENT_REMOVE, SEATING_COMPONENT_RENAME, SEATING_COMPONENT_MOVE, SEATING_RETRIEVE_OPTIONS } from "./setup/SeatingSetupContextMenuAction";
import { Popup } from "../../PopupHost";
import { seatingGetNextId, seatingGetNextCaption } from "./setup/SeatingSetupFunctions";
import Switch from "../../../components/Switch";

let nextId = 0;

const getRenderer = (update, callback) => ({
    bar: component => <SeatingBar key={component.id || nextId++} component={component} callback={callback} update={update} />,
    door: component => <SeatingDoor key={component.id || nextId++} component={component} callback={callback} update={update} />,
    room: component => <SeatingRoom key={component.id || nextId++} component={component} callback={callback} update={update} />,
    table: component => <SeatingTable key={component.id || nextId++} component={component} callback={callback} update={update} />,
    wall: component => <SeatingWall key={component.id || nextId++} component={component} callback={callback} update={update} />
});

const builtInUpdate = {
    [SEATING_COMPONENT_DUPLICATE]: (component, layout) => {
        const nextId = seatingGetNextId(layout.components, component.id, component.type);
        const nextCaption = seatingGetNextCaption(layout.components, component.caption);
        const components = [...layout.components, { ...component, id: nextId, caption: nextCaption, x: (component.x || 0) + 16, y: (component.y || 0) + 16 }];
        return { ...layout, components }
    },
    [SEATING_COMPONENT_REMOVE]: (component, layout) => {
        const components = layout.components.filter(c => c !== component);
        return { ...layout, components }
    },
    [SEATING_COMPONENT_RENAME]: (component, layout, update) => {
        Popup.configuration({
            title: `Rename ${component.caption}`,
            settings: [
                { type: "text", id: "id", caption: "Id", value: component.id, editable: false },
                { type: "text", id: "caption", caption: "Caption", value: component.caption }
            ]
        }).then(result => {
            if (result) {
                const newComponent = { ...component, id: result.id, caption: result.caption };
                const components = [...layout.components.filter(c => c !== component), newComponent];
                update({ ...layout, components });
            }
        });
    },
    [SEATING_COMPONENT_MOVE]: (component, layout, update, context) => {
        const newComponent = { ...component, x: context.componentPosition.x, y: context.componentPosition.y };
        const components = [...layout.components.filter(c => c !== component), newComponent];
        update({ ...layout, components });
    }
};

export class SeatingFloor extends Component {
    constructor(props) {
        super(props);
        this._renderer = getRenderer((component, content) => this._updateLayout(component, content), action => this._callback(action));
        this.state = {
            optionSnapToGrid: false
        };
    }

    _callback(action) {
        switch (action) {
            case SEATING_RETRIEVE_OPTIONS:
                return {
                    snapToGrid: this.state.optionSnapToGrid
                };
        }
    }

    _updateLayout(component, content) {
        let layoutNew;
        const { layout, update } = this.props;

        if (typeof content === "function") {
            layoutNew = content(layout, update);
        } else {
            var action = builtInUpdate[content.action];
            if (typeof action === "function") {
                layoutNew = action(component, layout, update, content);
            }
        }
        if (layoutNew && layoutNew !== layout)
            update(layoutNew);
    }

    render() {
        const { layout, location } = this.props;

        return (
            <div className={this.state.optionSnapToGrid ? 'seating-floor seating-floor--snap-to-grid' : 'seating-floor'}>
                {layout.components.filter(comp => comp.location === location).map(component => this._renderer[component.type](component))}
                <div className="snap-to-grid">
                    <Switch caption="Snap to grid" value={this.state.optionSnapToGrid} onChange={snapToGrid => this.setState({ optionSnapToGrid: snapToGrid })} />
                </div>
            </div>
        );
    }
}
