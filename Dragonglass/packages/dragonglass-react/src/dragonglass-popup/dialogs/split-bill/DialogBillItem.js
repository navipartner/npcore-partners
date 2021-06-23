import React, { Component } from "react";

export class DialogBillItem extends Component {
    constructor(props) {
        super(props);
        this._ref = React.createRef();
    }

    componentDidMount() {
        const component = this._ref.current;

        component.addEventListener("mousedown", this._mouseDown = (e) => {
            const controlAddInRect = document.getElementById("controlAddIn").getBoundingClientRect();
            const offset = { x: e.offsetX + controlAddInRect.x, y: e.offsetY + controlAddInRect.y };
            const node = component.cloneNode(true);
            node.className += " dragging";
            node.style.pointerEvents = "none";
            component.parentNode.append(node);

            const setNodeStyle = (e, node) => {
                node.style.width = `${component.getBoundingClientRect().width}px`;
                node.style.left = `${e.clientX - offset.x}px`;
                node.style.top = `${e.clientY - offset.y}px`;
            };

            setNodeStyle(e, node);
            document.addEventListener("mousemove", this._mouseMove = e => {
                setNodeStyle(e, node);
            });

            this._cleanUp = () => {
                const component = this._ref.current;
                component.style.pointerEvents = "all";
                component.parentNode.removeChild(node);
                this._cleanUp = null;
            };

            const endDragging = () => {
                this.cleanUp();
                this.removeDragEventListeners();
                this.props.onEndDragItem();
            }

            document.addEventListener("mouseup", this._mouseUp = endDragging);
            window.addEventListener("blur", this._blur = endDragging);

            this.props.onStartDragItem();
        });
    }

    cleanUp() {
        if (typeof this._cleanUp === "function")
            this._cleanUp();
    }

    componentWillUnmount() {
        this.cleanUp();
        const component = this._ref.current;
        component.removeEventListener("mousedown", this._mouseDown);
        this.removeDragEventListeners();
    }

    removeDragEventListeners() {
        const component = this._ref.current;

        if (this._mouseUp)
            document.removeEventListener("mouseup", this._mouseUp);

        if (this._mouseMove)
            document.removeEventListener("mousemove", this._mouseMove);

        if (this._blur)
            window.removeEventListener("blur", this._blur);

        this._mouseUp = null;
        this._mouseMove = null;
        this._blur = null;
    }

    render() {
        return (
            <tr
                id={this.props.id}
                className={`${this.props.className}`}
                ref={this._ref}
            >
                {this.props.children}
            </tr>
        );
    }
};