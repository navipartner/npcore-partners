import React from "react";
import Grid from "../../components/Grid/Grid";
import { DialogBase } from "./DialogBase";
import { DialogButtons } from "./DialogButtons";
import { DataType } from "../../enums/DataType";
import { StateStore } from "../../redux/StateStore";
import {
  copyDataSetAction,
  deleteDataSetAction,
} from "../../redux/actions/dataActions";
import { localize, GlobalCaption } from "../../components/LocalizationManager";

let nextDataSetId = 0;

export class DialogCalendarPlusGrid extends DialogBase {
  constructor(props) {
    super(props);
    this._refs = {
      calendar: React.createRef(),
    };

    if (!this._content.date) this._content.date = new Date();

    if (typeof this._content.date === "string")
      this._content.date = DataType.behavior[DataType.DATETIME].parse(
        this._content.date
      );

    this._tempDataSource = `TEMP.${
      this._content.dataSource
    }.copy${++nextDataSetId}`;
    StateStore.dispatch(
      copyDataSetAction(this._content.dataSource, this._tempDataSource)
    );
  }

  _disposeTempDataSet() {
    StateStore.dispatch(deleteDataSetAction(this._tempDataSource));
  }

  dismiss() {
    this._disposeTempDataSet();
    this._interface.close(null);
  }

  accept() {
    const { selectedDates } = this._datePicker;
    const date =
      selectedDates && selectedDates.length ? selectedDates[0] : new Date();
    date.setHours(date.getHours() - date.getTimezoneOffset() / 60);

    const selections = {};
    const state = StateStore.getState().data.sets[this._tempDataSource];
    if (state) {
      for (let i = 0; i < state._selections.length; i++) {
        selections[i] = state._selections[i];
      }
      selections.count = state._selections.length;
    }

    const result = {
      date,
      rows: selections,
    };
    this._disposeTempDataSet();
    this._interface.close(result);
  }

  componentDidMount() {
    this._datePicker = $(this._refs.calendar.current)
      .datepicker()
      .data("datepicker");

    this._datePicker.selectDate(this._content.date);
  }

  getBody() {
    return (
      <>
        <div className="datepicker-host">
          <div
            ref={this._refs.calendar}
            id="dialog-calendarplusgrid-datepicker"
          ></div>
        </div>
        <Grid
          layout={{
            type: "grid",
            id: "salesLines",
            fontSize: "normal",
            dataSource: this._tempDataSource,
            base: "45%",
            control: "dataGrid",
            showSelectColumn: true,
          }}
        ></Grid>
      </>
    );
  }

  getButtons() {
    return (
      <DialogButtons
        buttons={[
          {
            id: "button-dialog-ok",
            caption: localize(GlobalCaption.FromBackEnd.Global_OK),
            click: this.accept.bind(this),
          },
          {
            id: "button-dialog-cancel",
            caption: localize(GlobalCaption.FromBackEnd.Global_Cancel),
            click: this.dismiss.bind(this),
          },
        ]}
      />
    );
  }
}
