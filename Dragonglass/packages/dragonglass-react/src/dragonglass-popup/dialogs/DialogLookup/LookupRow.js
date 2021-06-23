import React from "react";

const Cell = React.memo(props => {
    const { control, row } = props;
    const { className, caption, width, fieldNo } = control;

    return (
        <div className={`lookup-entry-line-cell ${control.align ? "lookup-entry-line-cell--align-" + control.align : ""} ${control.fontSize ? "lookup-entry-line-cell--font-size-" + control.fontSize : ""} ${className || ""}`} style={width ? { width: width } : {}}>
            { caption ? <span className="lookup-entry-line-cell__caption">{caption}</span> : null}
            <span className="lookup-entry-line-cell__value">{row[fieldNo]}</span>
        </div >
    );
});

const Line = React.memo(props => {
    const { line, row } = props;
    const { className, controls, main } = line;

    return (
        <div className={`lookup-entry-line ${className || ""} ${main === true ? "lookup-entry-line--main" : ""}`}>
            {controls.map((control, key) => <Cell key={key} control={control} row={row} />)}
        </div>
    )
});

export const LookupRow = React.memo(props => {
    const { row, layout, selected, onSelect } = props;
    const { className, rows } = layout;

    return (
        <div className={`lookup-entry ${className || ""} ${selected ? "lookup-entry--selected" : ""}`} onClick={() => onSelect(row)}>
            { rows.map((line, key) => <Line key={key} line={line} row={row} />)}
        </div >
    );
});
