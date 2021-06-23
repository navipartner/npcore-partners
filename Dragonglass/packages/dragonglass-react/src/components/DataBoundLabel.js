import React from "react";
import { buildClass } from "../classes/functions";
import DataBoundCaption from "./DataBoundCaption";

const DataBoundLabel = props => {
    const { id, dataSourceName, className } = props;
    const additional = {};
    props.field && (additional.field = props.field);
    props.total && (additional.total = props.total);
    return (
        <div className={buildClass("label", className)} id={id}>
            <DataBoundCaption className="value" dataSourceName={dataSourceName} {...additional} key="value" />
        </div>
    )
};

export default DataBoundLabel;