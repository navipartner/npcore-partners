import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState";
import {
    DRAGONGLASS_NOTIFICATION_PANEL_SHOW,
    DRAGONGLASS_NOTIFICATION_NEW,
    DRAGONGLASS_NOTIFICATION_UPDATE,
    DRAGONGLASS_NOTIFICATION_CLOSE
} from "../actions/notificationActionTypes";
import { newNotification, showNotificationPanel } from "../actions/notificationActions";
import { snoozeNotification } from "../actions/notificationActions";
import { NotificationUpdateType, NotificationState } from "../../dragonglass-notifications/NotificationConstants";

export default createReducer(initialState.notifications, {
    [DRAGONGLASS_NOTIFICATION_PANEL_SHOW]: (state, payload) => ({
        ...state,
        entries: state.entries.map(entry => {
            if (entry.state === NotificationState.TOAST)
                entry = {...entry, state: NotificationState.TOAST_HIDING};
            return entry;
        }),
        panelVisible: payload
    }),

    [DRAGONGLASS_NOTIFICATION_NEW]: (state, payload) => ({ ...state, entries: [...state.entries, payload] }),

    [DRAGONGLASS_NOTIFICATION_UPDATE]: (state, payload) => {
        const newState = { ...state, entries: [] };
        const notification = { ...state.entries.find(n => n.id === payload.id) };
        if (!notification)
            return state;

        switch (payload.action) {
            case NotificationUpdateType.HIDE_TOAST:
                notification.state = NotificationState.TOAST_HIDING;
                break;
            case NotificationUpdateType.MINIMIZE:
                notification.state = NotificationState.MINIMIZED;
                break;
            case NotificationUpdateType.SNOOZE:
                notification.state = NotificationState.SNOOZED;
                break;
            case NotificationUpdateType.SHOW:
                notification.state = NotificationState.TOAST
                break;
        }

        for (var n of state.entries) {
            if (n.id !== payload.id) {
                newState.entries.push(n);
                continue;
            }

            newState.entries.push(notification);
        }

        return newState;
    },

    [DRAGONGLASS_NOTIFICATION_CLOSE]: (state, payload) => ({ ...state, entries: [...state.entries.filter(n => n.id !== payload)] })
});

const notificationsMap = {
    state: state => ({ notifications: state.notifications.entries, panelVisible: state.notifications.panelVisible }),
    dispatch: dispatch => ({
        newNotification: notification => dispatch(newNotification(notification)),
        snoozeNotification: notification => dispatch(snoozeNotification(notification)),
        showPanel: visible => dispatch(showNotificationPanel(visible))
    }),
    enhancer: {
        areStatesEqual: (next, prev) => next.notifications === prev.notifications
    }
};

const notificationsPanelVisibleMap = {
    state: state => ({ panelVisible: state.notifications.panelVisible }),
    enhancer: {
        areStatesEqual: (next, prev) => next.notifications.panelVisible === prev.notifications.panelVisible
    }
};

export const bindComponentToNotificationsState = component => bindToMap(component, notificationsMap);
export const bindComponentToNotificationsPanelVisibleState = component => bindToMap(component, notificationsPanelVisibleMap);
