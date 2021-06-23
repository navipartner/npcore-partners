import {
    DRAGONGLASS_NOTIFICATION_NEW,
    DRAGONGLASS_NOTIFICATION_UPDATE,
    DRAGONGLASS_NOTIFICATION_PANEL_SHOW,
    DRAGONGLASS_NOTIFICATION_CLOSE
} from "./notificationActionTypes";

import { NotificationUpdateType } from "../../dragonglass-notifications/NotificationConstants";
import { DEFAULT_TOAST_SCREEN_TIME_SECONDS } from "../../dragonglass-notifications/NotificationConstants";
import { NotificationState } from "../../dragonglass-notifications/NotificationConstants";

const autoHideNotification = (notificationId, dispatch, minimizeAfterSeconds = DEFAULT_TOAST_SCREEN_TIME_SECONDS) => {
    setTimeout(
        () => {
            dispatch({
                type: DRAGONGLASS_NOTIFICATION_UPDATE,
                payload: {
                    id: notificationId,
                    action: NotificationUpdateType.HIDE_TOAST
                }
            });

            setTimeout(
                () => {
                    dispatch({
                        type: DRAGONGLASS_NOTIFICATION_UPDATE,
                        payload: {
                            id: notificationId,
                            action: NotificationUpdateType.MINIMIZE,
                        }
                    });
                },
                1000);
        },
        minimizeAfterSeconds * 1000);
};

/**
 * Shows or hides the notification panel.
 * @param {Boolean} visible Requested visible state of the notification panel.
 */
export const showNotificationPanel = visible => ({
    type: DRAGONGLASS_NOTIFICATION_PANEL_SHOW,
    payload: visible
});

let lastId = 0;

/**
 * Shows a notification (stores it in the state store). After specified time (or default notification toast time)
 * elapses, the minimize update is dispatched.
 * @param {Object} notification Notification to show.
 */
export const newNotification = notification => dispatch => {
    const notificationId = ++lastId;

    dispatch({
        type: DRAGONGLASS_NOTIFICATION_NEW,
        payload: {
            id: notificationId,
            state: NotificationState.TOAST,
            ...notification
        }
    });

    autoHideNotification(notificationId, dispatch, notification.minimizeAfterSeconds);
};

/**
 * Snoozes a notification (hides it from view). After 5 minutes elapse, the notification is shown again.
 * @param {Object} dispatch Notification to snooze
 */
export const snoozeNotification = notificationId => dispatch => {
    // Start bz dispatching a snooze
    dispatch({
        type: DRAGONGLASS_NOTIFICATION_UPDATE,
        payload: {
            id: notificationId,
            action: NotificationUpdateType.SNOOZE
        }
    });

    // Then proceed by showing it after 5 minutes
    setTimeout(
        () => {
            dispatch({
                type: DRAGONGLASS_NOTIFICATION_UPDATE,
                payload: {
                    id: notificationId,
                    action: NotificationUpdateType.SHOW
                }
            });

            autoHideNotification(notificationId, dispatch);
        },
        5 * 60 * 1000);
};

/**
 * Marks a notification as completed. This doesn't remove the notification from the state, but merely makes sure
 * it isn't shown on screen.
 * @param {Number} id Id of the notification to complete
 */
export const closeNotification = id => ({
    type: DRAGONGLASS_NOTIFICATION_CLOSE,
    payload: id
});
