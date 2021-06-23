import React, { Component } from "react";
import { bindComponentToDataSourceState } from "../../redux/reducers/dataReducer";
import { gridColumns } from "./gridColumns";

class GridHead extends Component {
  render() {
    const columns = gridColumns(
      this.props.columns,
      this.props.dataSource.columns
    );

    return (
      <thead>
        <tr>
          {columns.map((column) => (
            <th key={column.fieldId} width={`${column.width}%`}>
              {column.caption}
            </th>
          ))}
        </tr>
      </thead>
    );
  }
}

export default bindComponentToDataSourceState(GridHead);
