import React, { Component } from "react";
import { localize, GlobalCaption } from "../LocalizationManager";
import { bindComponentToNotificationsState } from "../../redux/reducers/notificationsReducer";

class NotificationMessagesUnbound extends Component {
    render() {
        const { notifications, showPanel, panelVisible } = this.props;
        const any = !!notifications.length;

        return (
            <div
                title={
                    localize(
                        any
                            ? GlobalCaption.NotificationTooltips.Messages.MessagesAvailable
                            : GlobalCaption.NotificationTooltips.Messages.NoMessages
                    )
                        .replace(
                            /\{0\}/gi,
                            notifications.length.toString())
                }
                className={`${
                    notifications.length
                        ? "has-notifications fas fa-comment" :
                        "far fa-comment"
                    }`}
                onClick={() => showPanel(!panelVisible)}
            />
        );
    }
}

export const NotificationMessages = bindComponentToNotificationsState(NotificationMessagesUnbound);
