import React, { useRef, useState } from "react";
import { LookupLoadingRow } from "./LookupLoadingRow";
import { LookupRow } from "./LookupRow";

export const LookupBody = props => {
    const { data, hasMore, configuration, requestMore, updateSelected } = props;
    const { layout, className, multiSelect, styleSheet } = configuration;

    const dom = useRef();
    const [selected, setSelected] = useState([]);

    const selectRow = row => {
        let selectedNew;

        switch (multiSelect) {
            // Each row is individually selected and deselected (click toggles selected state of each row)
            case "toggle":
                if (!selected.includes(row)) {
                    // The row is not selected, let's select it
                    selectedNew = [...selected, row];
                } else {
                    // The row is selected, we need to unselect it
                    selectedNew = selected.filter(r => r !== row);
                }
                break;

            // Fast toggling works like this:
            // - Clicking on an unselected row selects it
            // - Clicking on a row that's already selected:
            //   a) if it's the only row that's selected, all rows are selected
            //   b) if more rows are selected, then unselects all row except the clicked one
            case "fast":
                if (selected.includes(row)) {
                    if (selected.length !== data.length && selected.length === 1) {
                        // Case a)
                        selectedNew = [...data];
                    } else {
                        // Case b)
                        selectedNew = [row];
                    }
                } else {
                    selectedNew = [...selected, row];
                }
                break;

            // No multi-select, clicking a row simply toggles its selected state
            default:
                if (selected.includes(row)) {
                    // The row is already selected, let's unselect it
                    selectedNew = [];
                } else {
                    // The row is not selected, let's select it
                    selectedNew = [row];
                }
                break;
        }

        if (selectedNew !== selected) {
            updateSelected(selectedNew);
            setSelected(selectedNew);
        }
    }

    return (
        <div ref={dom} className="lookup-content-outer">
            {styleSheet && typeof styleSheet === "string" ? <style>{styleSheet}</style> : null}
            <div className={`lookup-content ${className || ""}`}>
                {data ? data.map((row, key) => <LookupRow key={key} row={row} layout={layout} selected={selected.includes(row)} onSelect={selectRow} />) : null}
                {hasMore ? <LookupLoadingRow root={dom} refresh={requestMore} /> : null}
            </div>
        </div>
    )
}
