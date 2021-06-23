import React, { Component } from "react";
import { bindComponentToNotificationsState } from "../redux/reducers/notificationsReducer";
import { NotificationEntry } from "./NotificationEntry";
import { NotificationState } from "./NotificationConstants";
import SimpleBar from "simplebar-react";

class NotificationsContentUnbound extends Component {
    render() {
        const { notifications } = this.props;

        return (
            <div className="notifications-panel__content">
                <SimpleBar>
                    {
                        notifications.filter(n => n.state === NotificationState.MINIMIZED || n.state === NotificationState.TOAST_HIDING || n.state === NotificationState.TOAST).map((notification, id) => <NotificationEntry key={id} notification={notification} />)
                    }
                </SimpleBar>
            </div>
        );
    }
}

export const NotificationsContent = bindComponentToNotificationsState(NotificationsContentUnbound);
