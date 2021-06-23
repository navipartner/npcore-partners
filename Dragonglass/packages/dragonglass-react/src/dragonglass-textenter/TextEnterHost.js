import React, { Component } from "react";
import { bindComponentToTextEnterState } from "../redux/reducers/textEnterReducer";
import TextEnterEntry from "./TextEnterEntry";

class TextEnterHost extends Component {
    shouldComponentUpdate(next) {
        return next.textEnter !== this.props.textEnter;
    }

    render() {
        const entries = this.props.textEnter;
        const hostId = this.props.id;
        return (
            <div className="text-enter">
                {
                    entries.map((entry, index) => <TextEnterEntry hostId={hostId} id={entry.id} key={entry.id} ordinal={index} />)
                }
            </div>
        );
    }
}

export default bindComponentToTextEnterState(TextEnterHost);
