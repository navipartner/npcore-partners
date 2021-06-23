import React from "react";

export const InvalidControl = ({ control }) => {
    const { type, ...props } = control;

    return (
        <div className="invalid-control">
            <span className="invalid-control__caption">Invalid control: {type}</span>
            <span className="invalid-control__content">Content: {JSON.stringify(props)}</span>
        </div>
    );
}
