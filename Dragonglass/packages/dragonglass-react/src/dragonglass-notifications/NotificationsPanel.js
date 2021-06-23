import React, { Component } from "react";
import { bindComponentToNotificationsPanelVisibleState } from "../redux/reducers/notificationsReducer";
import { NotificationsContent } from "./NotificationsContent";

class NotificationsPanelUnbound extends Component {
    render() {
        const { panelVisible } = this.props;

        return (
            <div className={`notifications-panel ${panelVisible ? "notifications-panel--visible" : "notifications-panel--invisible"}`}>
                <NotificationsContent />
            </div>
        );
    }
}

export const NotificationsPanel = bindComponentToNotificationsPanelVisibleState(NotificationsPanelUnbound);
