import React, { Component } from "react";
import { NAV } from "dragonglass-nav";
import { NotificationBusy } from "./NotificationBusy";
import { NotificationMessages } from "./NotificationMessages";

export class StatusBarNotifications extends Component {
    constructor(props) {
        super(props);

        this.state = {
            busy: false
        };

        this._busyChanged = this._busyChanged.bind(this);
    }
    componentDidMount() {
        NAV.instance.subscribeBusyChanged(this._busyChanged)
    }

    componentWillUnmount() {
        NAV.instance.unsubscribeBusyChanged(this._busyChanged);
    }

    _busyChanged(busy) {
        this.setState({ busy: busy });
    }

    render() {
        const { busy } = this.state;
        return (
            <div className="statusbar__notifications">
                <NotificationMessages />
                <NotificationBusy busy={busy} />
            </div>
        );
    }
}
