import React, { Component } from "react";
import { SeatingSetupContextMenu } from "./setup/SeatingSetupContextMenu";
import { SEATING_COMPONENT_DUPLICATE, SEATING_COMPONENT_REMOVE, SEATING_COMPONENT_RENAME, SEATING_COMPONENT_MOVE, SEATING_RETRIEVE_OPTIONS } from "./setup/SeatingSetupContextMenuAction";

let hideActiveMenu = null;

/**
 * This class represents a logical root seating layout component. It contains all the necessary functionality
 * of a seating component without providing specific component UI. This class is not concerned with UI of a
 * component; rather, it's concerned with functionality and interaction.
 *
 * @export
 * @class SeatingComponent
 * @extends {Component}
 */
export class SeatingComponent extends Component {
    constructor(props) {
        super(props);
        this._ref = React.createRef();

        this.state = {
            menuVisible: false,
            isDown: false,
            isMoving: false,
            componentPosition: { x: this.props.component.x || 0, y: this.props.component.y || 0 },
            offsetPosition: { x: 0, y: 0 }
        };
    }

    componentDidMount() {
        const component = this._ref.current;

        component.addEventListener("mousedown", this._mouseDown = (e) => {
            this.setState({
                isDown: true,
                offsetPosition: {
                    x: component.offsetLeft - e.clientX,
                    y: component.offsetTop - e.clientY
                }
            });
        });

        document.addEventListener("mouseup", this._mouseUp = () => {
            this.setState({
                isDown: false
            });
        });

        document.addEventListener("mousemove", this._mouseMove = (e) => {
            e.preventDefault();
            if (this.state.isDown) {
                const { component, update, callback } = this.props;
                const snap = callback(SEATING_RETRIEVE_OPTIONS).snapToGrid;
                const x = e.clientX + this.state.offsetPosition.x;
                const y = e.clientY + this.state.offsetPosition.y;
                const xr = Math.ceil(x / 30) * 30;
                const yr = Math.ceil(y / 30) * 30;
                this.setState({
                    isMoving: true,
                    menuVisible: false,
                    componentPosition: {
                        x: snap ? xr : x,
                        y: snap ? yr : y
                    }
                });

                const { componentPosition } = this.state;
                update(component, { action: SEATING_COMPONENT_MOVE, componentPosition });
            }
        });
    }

    componentWillUnmount() {
        if (this.state.menuVisible)
            hideActiveMenu = null;

        const component = this._ref.current;
        component.removeEventListener("mousedown", this._mouseDown);
        document.removeEventListener("mouseup", this._mouseUp);
        document.removeEventListener("mousemove", this._mouseMove);
    }

    getContent() {
        return null;
    }

    getOptions() {
        return [];
    }

    _getOptions() {
        var { update, component } = this.props;

        return [
            { icon: "", caption: "Duplicate", onClick: () => update(component, { action: SEATING_COMPONENT_DUPLICATE }) },
            { icon: "", caption: "Remove", onClick: "remove", onClick: () => update(component, { action: SEATING_COMPONENT_REMOVE }) },
            { icon: "", caption: "Rename", onClick: "rename", onClick: () => update(component, { action: SEATING_COMPONENT_RENAME }) },
            ...this.getOptions()
        ]
    }

    _toggleMenu() {
        if (this.state.isMoving) {
            this.setState({ isMoving: false });
            return;
        }

        let thisVisible = !this.state.menuVisible;
        if (thisVisible) {
            hideActiveMenu && hideActiveMenu();
            hideActiveMenu = () => {
                hideActiveMenu = null;
                this.setState({ menuVisible: false });
            }
        }
        this.setState({ menuVisible: thisVisible });
    }

    render() {
        // Use x and y to position the component on screen
        const { type } = this.props.component;
        const { x, y } = this.state.componentPosition;

        return (
            <div onClick={() => this._toggleMenu()} style={{ top: `${y}px`, left: `${x}px` }} draggable={true} ref={this._ref} className={this.state.menuVisible ? `seating seating--${type} is-active` : `seating seating--${type}`}>
                {this.getContent()}
                <SeatingSetupContextMenu visible={this.state.menuVisible} options={this._getOptions()} />
            </div>
        );
    }
}
