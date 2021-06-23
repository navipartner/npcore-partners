import React, { Component } from "react";
import GridRow from "./GridRow";
import { bindComponentToDataSetState } from "../../redux/reducers/dataReducer";
import { gridColumns } from "./gridColumns";

const extractLineNo = (position) => {
  const pat = /Line No\.=CONST\((?<lineNo>\d+)\)/;
  const result = position.match(pat);
  let val =
    (result && result.groups && Number.parseInt(result.groups.lineNo)) || 0;
  return val;
};

const getOrderedRows = (rows, reverse) => {
  // Even though it seems to be a potential performance issue, this is fast. From performance measurements:
  // Sorting 10 rows took 0.09499999578110874 ms
  // Sorting 25 rows took 0.15499999426538125 ms
  // Sorting 50 rows took 0.26000000070780516 ms
  // Sorting 100 rows took 0.40499999886378646 ms
  // Sorting 1000 rows took 2.8049999964423478 ms
  // That is pretty fast, because most transactions are <20 items, and even on biggest ones it won't be noticeable

  // Extracting numeric line number information from the primary key
  rows = rows.map((row) => ({
    ...row,
    __sort_order__: extractLineNo(row.position),
  }));

  // Sorting based on configuration options
  const reverseFactor = reverse ? 1 : -1;
  rows.sort((left, right) =>
    left.__sort_order__ < right.__sort_order__
      ? 1 * reverseFactor
      : left.__sort_order__ > right.__sort_order__
      ? -1 * reverseFactor
      : 0
  );

  return rows;
};

class GridBody extends Component {
  render() {
    const {
      data,
      dataSource,
      dataSourceName,
      showSelectColumn,
      reverse,
    } = this.props;

    const t1 = performance.now();
    const rows = getOrderedRows(data.rows, reverse);
    const t2 = performance.now();
    console.log(`Sorting ${rows.length} rows took ${t2 - t1} ms`);
    const columns = gridColumns(
      this.props.columns,
      this.props.dataSource.columns
    );
    return (
      <tbody>
        {rows.map((row) => (
          <GridRow
            key={row.position}
            position={row.position}
            dataSource={dataSource}
            dataSourceName={dataSourceName}
            showSelectColumn={showSelectColumn}
            row={row}
            columns={columns}
          />
        ))}
      </tbody>
    );
  }
}

export default bindComponentToDataSetState(GridBody);
