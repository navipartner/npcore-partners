import React, { PureComponent } from "react";
import { replaceBindings } from "../classes/dataBindingEvaluation";
import { FormatAs } from "../enums/DataType";
import { bindComponentToDataSetCurrentRowState } from "../redux/reducers/dataReducer";
import sliceNonHtmlCaption from "./SliceNonHtmlCaption";

// TODO: This should be the same control as "running dots" in the item grid (when inserting new items). Instead of showing "<unbound>", show running dots!
const UNBOUND_CAPTION = <div>{"<...>"}</div>;

/**
 * Represents a data-bound caption that updates when the underlying data state changes.
 * Properties:
 * @property {Boolean} inline Indicates whether the caption content represents HTML content and should be rendered as inline HTML
 * @property {String} dataSourceName Defines the name of the data source from which to read the caption value.
 * @property {String} field Defines the field from the current row from the indicated data source.
 * @property {Object} currentRow (Assigned from Redux) Contains the currently active row in the indicated data source.
 * @property {Boolean} bound (Assigned from Redux) Indicates whether binding was successful.
 * @property {String} caption (Assigned from Redux) Contains the caption to render.
 */
class DataBoundCaption extends PureComponent {
  render() {
    let {
      className,
      inline,
      caption,
      bound,
      currentRow,
      fallbackValue,
      set,
    } = this.props;
    const classHolder = {};
    if (className) classHolder.className = className;

    if (typeof caption === "number") {
      caption = FormatAs.decimal(caption);
    }

    if (inline) {
      const boundCaption = replaceBindings(caption, currentRow, set);
      const slicedCaption = sliceNonHtmlCaption(boundCaption);

      return (
        <span
          className="button__inner-content"
          {...classHolder}
          title={boundCaption}
          dangerouslySetInnerHTML={{
            __html: slicedCaption,
          }}
        ></span>
      );
    }

    return (
      (bound
        ? caption
        : fallbackValue !== undefined
        ? fallbackValue
        : UNBOUND_CAPTION) || null
    );
  }
}

export default bindComponentToDataSetCurrentRowState(DataBoundCaption);
