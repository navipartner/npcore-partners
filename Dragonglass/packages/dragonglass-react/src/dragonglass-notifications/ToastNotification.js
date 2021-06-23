import React, { Component } from "react";

export class ToastNotification extends Component {
    render() {
        const {caption, category, buttons } = this.props;
        return (
            <div className="toast-notification">
                <div className="toast-notification__caption">{caption}</div>
            </div>
        );
    }
}