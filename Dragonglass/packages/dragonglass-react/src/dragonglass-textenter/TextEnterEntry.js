import React, { Component } from "react";
import { bindComponentToTextEnterEntryState } from "../redux/reducers/textEnterReducer";

class TextEnterEntry extends Component {
    shouldComponentUpdate(newProps) {
        return this.props.entry !== newProps.entry || this.props.ordinal !== newProps.ordinal;
    }

    render() {
        const { entry, ordinal } = this.props;
        const { text, id } = entry;

        let className = `text-enter__entry ${entry.closing ? "is-closing" : ""} ordinal-${ordinal}`;
        return (
            <div id={`text-entry-${id}`} className={className}>
                {text}
            </div>
        );
    }
}

export default bindComponentToTextEnterEntryState(TextEnterEntry);
