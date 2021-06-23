import React, { Component } from "react";
import { StateStore } from "../redux/StateStore";
import { closeNotification } from "../redux/actions/notificationActions";
import { NotificationState } from "./NotificationConstants";

export class NotificationToast extends Component {
    render() {
        const { notification } = this.props;
        const { state } = notification;

        let additionalClass = "";
        switch (state) {
            case NotificationState.TOAST:
                additionalClass = "notification-toast--show";
                break;
            case NotificationState.TOAST_HIDING:
                additionalClass = "notification-toast--hiding";
                break;
        }

        return (
            <div className={`notification-toast ${additionalClass}`}>
                <div className="fal fa-xmark close" onClick={() => StateStore.dispatch(closeNotification(notification.id))} />
                <div className="notification__title">{notification.title}</div>
                <div className="notification__text">{notification.text}</div>
            </div>
        );
    }
}
