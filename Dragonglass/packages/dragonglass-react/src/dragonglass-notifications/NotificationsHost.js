import React, { Component } from "react";
import { bindComponentToNotificationsState } from "../redux/reducers/notificationsReducer";
import { NotificationToast } from "./NotificationToast";
import { NotificationState } from "./NotificationConstants";
import { TooManyInstancesError } from "../dragonglass-errors/TooManyInstancesError";
import { GlobalErrorDispatcher, GLOBAL_ERRORS } from "dragonglass-core";
import { GlobalCaption, localize } from "../components/LocalizationManager";

let singleton = null;

class NotificationsHostUnbound extends Component {
  constructor(props) {
    super(props);
    if (singleton)
      throw new TooManyInstancesError(
        "You cannot instantiate more than one instance of the NotificationsHost component per application."
      );

    this._unsubscribeOnGlobalCriticalError = null;
  }

  onGlobalCriticalError(message) {
    this.props.newNotification({
      title: localize(GlobalCaption.Error),
      text: message,
    });
  }

  componentDidMount() {
    singleton = this;

    const subscriber = (_, serialized) =>
      this.onGlobalCriticalError(serialized.message);
    this._unsubscribeOnGlobalCriticalError = () =>
      GlobalErrorDispatcher.removeEventListener(
        GLOBAL_ERRORS.CRITICAL_ERROR,
        subscriber
      );
    GlobalErrorDispatcher.addEventListener(
      GLOBAL_ERRORS.CRITICAL_ERROR,
      subscriber
    );
  }

  componentWillUnmount() {
    singleton = null;
  }

  render() {
    const { notifications } = this.props;

    return (
      <div className="notifications-host">
        {notifications.map((notification, id) =>
          notification.state === NotificationState.TOAST ||
          notification.state === NotificationState.TOAST_HIDING ? (
            <NotificationToast key={id} notification={notification} />
          ) : null
        )}
      </div>
    );
  }
}

export const NotificationsHost = bindComponentToNotificationsState(
  NotificationsHostUnbound
);
