import React, { Component } from "react";
import { bindComponentToDataSetState } from "../../../redux/reducers/dataReducer";
import { DataGridRow } from "./DataGridRow";
import { DataGridEmpty } from "./DataGridEmpty";
import SimpleBar from "simplebar-react";

class DataGrid extends Component {
  constructor(props) {
    super(props);
    this._activeChild = null;
  }

  _setActive(row) {
    if (this._activeChild) this._activeChild._setActive(false);

    this._activeChild = row;
  }

  render() {
    const { data, dataSource, dataSourceName, template } = this.props;

    return (
      <div
        className={
          data.rows.length
            ? "c-grid c-grid--data l-vertical"
            : "c-grid c-grid--data c-grid--empty l-vertical"
        }
      >
        <SimpleBar>
          {data.rows.length ? (
            data.rows.map((row) => (
              <DataGridRow
                key={row.position}
                position={row.position}
                dataSource={dataSource}
                dataSourceName={dataSourceName}
                template={template}
                parent={this}
                row={row}
              />
            ))
          ) : (
            <DataGridEmpty />
          )}
        </SimpleBar>
      </div>
    );
  }
}

export default bindComponentToDataSetState(DataGrid);
