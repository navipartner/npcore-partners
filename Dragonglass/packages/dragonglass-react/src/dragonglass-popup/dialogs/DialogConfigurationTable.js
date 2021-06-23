import React, { useState } from "react";
import { DialogBase } from "./DialogBase";
import { DialogButtons } from "./DialogButtons";
import Switch from "../../components/Switch";
import SimpleBar from "simplebar-react";
import { localize, GlobalCaption } from "../../components/LocalizationManager";

const ColumnCaption = (props) => (
  <td>
    <div className="column-caption">
      <span>{props.column.caption || null}</span>
      {props.column.icon ? <span className={props.column.icon}></span> : null}
    </div>
  </td>
);

const ColumnCell = (props) => (
  <td>
    {props.hasChildren ? null : (
      <Switch
        id={`${props.rowId}-${props.columnId}`}
        selector={() => props.selector()}
        updater={(value) => props.updater(value)}
      />
    )}
  </td>
);

const ToggleButton = (props) => (
  // props.expanded says in which state the toggle button is
  <span
    className={
      props.expanded
        ? "toggle-icon fa fa-chevron-down"
        : "toggle-icon fa fa-chevron-up"
    }
    onClick={() => props.click()}
  >
    {/*Expanded: {props.expanded ? "yes" : "no"} */}
  </span>
);

const Row = (props) => {
  let toggleSecondLevelShown, secondLevelShown;
  const { row, parentRowId, columns, selections, secondLevel, shown } = props;
  if (!secondLevel)
    [secondLevelShown, toggleSecondLevelShown] = useState(!!row.expanded);

  const hasRows = row.rows;
  const rowId = row.id;
  const trStyles = { style: {} };
  const trClass = { className: "" };
  if (!shown && secondLevel) trStyles.style.display = "none";

  if (secondLevel) trClass.className = "second-level";

  if (secondLevelShown) trClass.className = "has-second-level is-active";
  else if (hasRows) trClass.className = "has-second-level";

  return (
    <>
      <tr {...trClass} {...trStyles}>
        <td>
          <table>
            <tr>
              <td>
                <span className="row-caption">
                  {row.caption ? row.caption : null}
                </span>
                {hasRows ? (
                  <ToggleButton
                    expanded={secondLevelShown}
                    click={() => toggleSecondLevelShown(!secondLevelShown)}
                  />
                ) : null}
              </td>
              {columns.map((column, index) => (
                <ColumnCell
                  key={index}
                  rowId={row.id}
                  columnId={column.id}
                  hasChildren={!secondLevel && hasRows}
                  selector={() =>
                    secondLevel
                      ? !!(
                          selections[parentRowId] &&
                          selections[parentRowId][row.id] &&
                          selections[parentRowId][row.id][column.id]
                        )
                      : !!(selections[row.id] && selections[row.id][column.id])
                  }
                  updater={(value) => {
                    if (secondLevel) {
                      selections[parentRowId] = selections[parentRowId] || {};
                      selections[parentRowId][row.id] =
                        selections[parentRowId][row.id] || {};
                      selections[parentRowId][row.id][column.id] = value;
                      return;
                    }
                    selections[row.id] = selections[row.id] || {};
                    selections[row.id][column.id] = value;
                  }}
                />
              ))}
            </tr>
          </table>
        </td>
      </tr>
      {secondLevel || !hasRows
        ? null
        : row.rows.map((row, index) => (
            <Row
              shown={hasRows ? secondLevelShown : true}
              key={index}
              parentRowId={rowId}
              row={row}
              secondLevel={true}
              columns={columns}
              selections={selections}
            />
          ))}
    </>
  );
};

export class DialogConfigurationTable extends DialogBase {
  constructor(props) {
    super(props);

    this._selections = JSON.parse(JSON.stringify(this._content.selections));
  }

  accept() {
    this._interface.close(this._selections);
  }

  canAcceptWithEnterKeyPress() {
    return false;
  }

  canDismissByClickingOutside() {
    return false;
  }

  getBody() {
    const { columns, rows, selections, caption } = this._content;
    return (
      <div className="dialog__settings__body">
        {caption ? (
          <div className="dialog__caption">
            {<span dangerouslySetInnerHTML={{ __html: caption }}></span>}
          </div>
        ) : null}
        <SimpleBar>
          <table>
            <thead>
              <tr>
                <th>
                  <table>
                    <tr>
                      <td></td>
                      {columns.map((column, index) => (
                        <ColumnCaption column={column} key={index} />
                      ))}
                    </tr>
                  </table>
                </th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row, index) => (
                <Row
                  key={index}
                  row={row}
                  columns={columns}
                  selections={this._selections}
                />
              ))}
            </tbody>
          </table>
        </SimpleBar>
      </div>
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
