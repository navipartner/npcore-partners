import React from "react";
import { DialogBase } from "../DialogBase";
import { DialogButtons } from "../DialogButtons";
import { DialogBillTable } from "./DialogBillTable";
import SimpleBar from "simplebar-react";
import {
  localize,
  GlobalCaption,
} from "../../../components/LocalizationManager";
import { SplitBillDragDropCoordinator } from "./SplitBillDragDropCoordinator";

export class DialogSplitBill extends DialogBase {
  constructor(props) {
    super(props);

    this.state = {
      items: this._content.items,
      bills: [],
    };

    this.addBill = this._addBill.bind(this);

    this.dragCoordinator = new SplitBillDragDropCoordinator();
    this.dragCoordinator.subscribe((item, from, to) =>
      this.moveItemBetweenBills(item, from, to)
    );
  }

  _addBill() {
    this.setState({
      bills: [...this.state.bills, { id: Date.now(), items: [] }],
    });
  }

  accept() {
    this._interface.close(this.state);
  }

  canDismissByClickingOutside() {
    return false;
  }

  moveItemBetweenBills(item, fromBill, toBill) {
    const newState = { ...this.state };
    const source = fromBill === null ? newState : fromBill;
    const target = toBill === null ? newState : toBill;
    source.items = source.items.filter((existing) => item !== existing);
    target.items.push(item);
    this.setState(newState);
  }

  getBody() {
    return (
      <div className="dialog__split-bill__body">
        <div className="split-bill__container">
          <DialogBillTable
            id="table-1"
            className="bill-table"
            bill={null}
            items={this.state.items}
            dragCoordinator={this.dragCoordinator}
          />
        </div>
        <div className="split-bill__container">
          <SimpleBar>
            {this.state.bills.map((bill, id) => (
              <DialogBillTable
                key={id}
                bill={bill}
                items={bill.items}
                dragCoordinator={this.dragCoordinator}
              />
            ))}
          </SimpleBar>

          <div onClick={this.addBill} className="button">
            <div>
              <span className="button__caption">
                <span className="button__inner-content">Add New Bill</span>
              </span>
            </div>
          </div>
        </div>
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
