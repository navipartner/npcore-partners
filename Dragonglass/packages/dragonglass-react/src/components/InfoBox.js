import React, { Component } from "react";
import Label from "./Label";
import { buildClass } from "../classes/functions";
import DataBoundLabel from "./DataBoundLabel";
import { bindComponentToDataSourceState } from "../redux/reducers/dataReducer";
import { FormatAs } from "../enums/DataType";

const InfoBoxCaption = (props) => {
  const { row, title, className, dataSourceName, dataSource } = props;
  const leftRight = row && row.left && row.right;
  const additional = {};
  row.field && (additional.field = row.field);
  row.total && (additional.total = row.total);
  let { caption } = row;
  if (row.field && !caption) {
    const columns =
      (dataSource && dataSource.columns && dataSource.columns) || [];
    const column = columns.find((c) => c.fieldId === row.field) || {};
    caption = column.caption || "";
  }
  if ((row.field || row.total) && typeof caption === "number")
    caption = FormatAs.decimal(caption);

  const showFirstLine = (title && row.caption) || !title;
  const showSecondLine = !title || !row.caption || row.field || row.total;
  return (
    <div
      className={buildClass(
        "captionbox__datacaption",
        className,
        row.class,
        leftRight
      )}
    >
      {!leftRight
        ? [
            showFirstLine && (
              <Label
                className="captionbox__caption"
                caption={caption || ""}
                key="caption"
              ></Label>
            ),
            showSecondLine && (
              <DataBoundLabel
                className="captionbox__value"
                dataSourceName={dataSourceName}
                {...additional}
                key="value"
              />
            ),
          ]
        : [
            <InfoBoxCaption
              dataSource={dataSource}
              dataSourceName={dataSourceName}
              row={row.left}
              className="left"
              key="left"
            />,
            <InfoBoxCaption
              dataSource={dataSource}
              dataSourceName={dataSourceName}
              row={row.right}
              className="right"
              key="right"
            />,
          ]}
    </div>
  );
};

class InfoBox extends Component {
  render() {
    const { id, binding, dataSource, data } = this.props;
    if (!data.rows.length && binding.fallback)
      return <InfoBox {...this.props} binding={binding.fallback} />;

    const { captionSet } = binding;
    const dataSourceName = binding && binding.dataSource;
    return (
      <div className="captionbox" id={id}>
        {captionSet && captionSet.title && (
          <InfoBoxCaption
            title
            dataSource={dataSource}
            dataSourceName={dataSourceName}
            row={captionSet.title}
            className="captionbox__datacaption--title"
          />
        )}
        {captionSet &&
          Array.isArray(captionSet.rows) &&
          captionSet.rows.map((row, index) => (
            <InfoBoxCaption
              dataSource={dataSource}
              dataSourceName={dataSourceName}
              row={row}
              className={row.className}
              key={index}
            />
          ))}
      </div>
    );
  }
}

export default bindComponentToDataSourceState(InfoBox, { includeData: true });
