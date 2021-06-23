import React, { Component } from "react";
import { localize, GlobalCaption } from "../LocalizationManager";

export class NotificationBusy extends Component {
    render() {
        const { busy } = this.props;
        return (
            <div
                title={
                    localize(
                        busy
                            ? GlobalCaption.NotificationTooltips.BusyState.Busy
                            : GlobalCaption.NotificationTooltips.BusyState.Idle)
                }
                className={`${busy ? "is-busy" : ""} fas fa-gear`}>
            </div>
        );
    }
}
