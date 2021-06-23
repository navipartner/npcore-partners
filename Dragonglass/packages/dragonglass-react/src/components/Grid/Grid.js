import React, { Component } from "react";
import Panel from "../Panel";
import GridHead from "./GridHead";
import GridBody from "./GridBody";
import GridTotals from "./GridTotals";

class Grid extends Component {
  render() {
    const { id, layout, dataSource } = this.props;
    return (
      <div className="grid" id={id}>
        <Panel
          className={`grid__table grid__table--head ${
            layout.showSelectColumn ? "grid__table__head--showselectcolumn" : ""
          }`}
        >
          <table>
            <GridHead
              showSelectColumn={layout.showSelectColumn}
              dataSourceName={layout.dataSource}
              columns={layout.columns}
            />
          </table>
        </Panel>
        <Panel
          className={`grid__table grid__table--body ${
            layout.showSelectColumn ? "grid__table__body--showselectcolumn" : ""
          }`}
        >
          <table>
            <GridBody
              showSelectColumn={layout.showSelectColumn}
              dataSourceName={layout.dataSource}
              dataSource={dataSource}
              columns={layout.columns}
            />
          </table>
        </Panel>
        {layout.totals && (
          <GridTotals
            dataSourceName={layout.dataSource}
            dataSource={dataSource}
            totals={layout.totals}
          />
        )}
      </div>
    );
  }
}

export default Grid;
