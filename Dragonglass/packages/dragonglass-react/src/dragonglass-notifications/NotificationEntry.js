import React, { Component } from "react";
import { StateStore } from "../redux/StateStore";
import { closeNotification } from "../redux/actions/notificationActions";

export class NotificationEntry extends Component {
    render() {
        const { notification } = this.props;

        return (
            <div className="notification__entry">
                <div className="fal fa-xmark close" onClick={() => StateStore.dispatch(closeNotification(notification.id))} />
                <div className="notification__title">{notification.title}</div>
                <div className="notification__text">{notification.text}</div>
            </div>
        );
    }
}
