import React, { Component } from "react";
import scrollIntoView from "scroll-into-view-if-needed";
import ViewEventHost from "../EventHosts/ViewEventHost";
import { bindComponentToDataSetRepeaterCurrentRowState } from "../../redux/reducers/dataReducer";
import { DataType } from "../../enums/DataType";

const LINE_FORMAT_COLOR = "LineFormat.Color";
const LINE_FORMAT_WEIGHT = "LineFormat.Weight";
const LINE_FORMAT_STYLE = "LineFormat.Style";

const cellStyle = (column, fields) => {
  const style = {
    width: `${column.width}%`,
  };

  if (fields[LINE_FORMAT_COLOR]) {
    style.color = fields[LINE_FORMAT_COLOR];
  }

  if (fields[LINE_FORMAT_WEIGHT]) {
    style.fontWeight = fields[LINE_FORMAT_WEIGHT];
  }

  if (fields[LINE_FORMAT_STYLE]) {
    style.fontStyle = fields[LINE_FORMAT_STYLE];
  }

  return style;
};

const Columns = ({
  columns,
  row,
  showSelectColumn,
  active,
  toggleSelection,
}) => {
  return (
    <>
      {columns.map((column, index) => {
        let value = row.fields && row.fields[column.fieldId];
        value =
          row.pending && !value
            ? (value = <span></span>)
            : DataType.behavior[column.dataType].format(value);
        return (
          <td
            className={row.pending ? "loading" : ""}
            key={column.fieldId}
            style={cellStyle(column, row.fields)}
          >
            {showSelectColumn && index === 0 ? (
              <label className="custom-checkbox">
                <input
                  type="checkbox"
                  checked={active}
                  onChange={toggleSelection}
                />
                <span className="checkmark"></span>
              </label>
            ) : null}
            {value}
          </td>
        );
      })}
    </>
  );
};

let lastScrollIntoView = 0;

class GridRow extends Component {
  constructor(props) {
    super(props);
    this.refTr = React.createRef();
  }

  componentDidMount() {
    this.scrollIntoViewIfNeeded();
  }

  shouldComponentUpdate(nextProp) {
    return (
      nextProp.active !== this.props.active || nextProp.row !== this.props.row
    );
  }

  scrollIntoViewIfNeeded(instant) {
    let thisScrollIntoView = ++lastScrollIntoView;

    setTimeout(() => {
      if (thisScrollIntoView !== lastScrollIntoView) return;
      scrollIntoView(this.refTr.current, {
        behavior: instant ? "instant" : "smooth",
        scrollMode: "if-needed",
      });
    });
  }

  render() {
    const { active, row, showSelectColumn, columns } = this.props;
    const additional = {};
    active && (additional.className = "tr-highlight");
    return (
      <tr {...additional} ref={this.refTr} onClick={this.props.setActive}>
        <Columns
          columns={columns}
          row={row}
          showSelectColumn={showSelectColumn}
          toggleSelection={this.props.toggleSelection}
          active={active}
        />
        <ViewEventHost
          eventHandlers={{
            onChangeActiveView: (newView) =>
              setTimeout(
                () => this.props.active && this.scrollIntoViewIfNeeded(true)
              ),
          }}
        />
      </tr>
    );
  }
}

export default bindComponentToDataSetRepeaterCurrentRowState(GridRow);
