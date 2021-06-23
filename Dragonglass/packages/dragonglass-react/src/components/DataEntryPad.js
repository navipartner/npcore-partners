import React, { Component } from "react";

class DataEntryPad extends Component {
    render() {
        const { id, ...props } = this.props;
        return (
            <div className="dataentrypad" id={id} {...props}>
            </div>
        )
    }
}

export default DataEntryPad;