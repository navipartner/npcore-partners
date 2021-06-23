import React, { Component } from "react";
import { DialogBillItem } from "./DialogBillItem";

export class DialogBillTable extends Component {
    constructor(props) {
        super(props);
        this._ref = React.createRef();
    }

    componentDidMount() {
        const component = this._ref.current;

        component.addEventListener("mouseover", this._mouseOver = e => {
            const p = this.props;
            if (this.props.dragCoordinator.isValidTarget(this.props.bill)) {
                component.className = "grid grid--active-drop-area";
            };
        });

        component.addEventListener("mouseout", this._mouseOut = e => {
            component.className = "grid";
        });

        component.addEventListener("mouseup", this._mouseUp = e => {
            component.className = "grid";
            this.props.dragCoordinator.mouseUp(this.props.bill);
        });
    }

    componentWillUnmount() {
        const component = this._ref.current;

        if (this._mouseOver)
            component.removeEventListener("mouseover", this._mouseOver);
        if (this._mouseOut)
            component.removeEventListener("mouseout", this._mouseOut);
        if (this._mouseUp)
            component.removeEventListener("mouseup", this._mouseUp);
    }

    startDrag(item) {
        const { dragCoordinator, bill } = this.props;
        const component = this._ref.current;
        component.style.pointerEvents = "none";
        dragCoordinator.startDrag(item, bill);
    }

    endDrag() {
        const { dragCoordinator } = this.props;
        const component = this._ref.current;
        component.style.pointerEvents = "all";
        dragCoordinator.endDrag();
    }

    mouseUp() {
        const { dragCoordinator, bill } = this.props;
        const component = this._ref.current;
        component.style.pointerEvents = "all";
        this.dragCoordinator.mouseUp(bill);
    }

    render() {
        const { items } = this.props;

        return (
            <div className="grid" ref={this._ref}>
                <div className="grid__table grid__table--head">
                    <table>
                        <thead>
                            <tr>
                                <th>Description</th>
                                <th>Quantity</th>
                            </tr>
                        </thead>
                    </table>
                </div>

                <div className="grid__table grid__table--body">
                    <table>
                        <tbody id={this.props.id} className="bill-table bill-table--split">
                            {items.map((item, id) =>
                                <DialogBillItem
                                    id={`bill-item-${id}`}
                                    key={id}
                                    className="bill-item"
                                    draggable="true"
                                    item={item}
                                    onStartDragItem={() => this.startDrag(item)}
                                    onEndDragItem={() => this.endDrag()}
                                >
                                    <td>{item.caption}</td>
                                    <td>{item.qty}</td>
                                </DialogBillItem>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        );
    }
};