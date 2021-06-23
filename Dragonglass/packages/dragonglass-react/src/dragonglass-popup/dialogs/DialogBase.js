import React from "react";
import { DialogButtons } from "./DialogButtons";
import { PopupRuntimeError } from "../PopupError";
import { localize, GlobalCaption } from "../../components/LocalizationManager";

export class DialogBase {
    /**
     * Creates an instance of DialogBase.
     * @param {Object} props Properties
     * @memberof DialogBase
     */
    constructor(props) {
        this._interface = props._interface;
        this._type = props.type;
        this._content = props.content;
        this._mounted = false;
        if (typeof this._content === "string")
            this._content = {
                caption: this._content
            };
        this.state = null;
    }

    setState(newState) {
        // Making sure to not update state on unmounted component!
        if (!this._mounted)
            return;

        this.state = {...this.state, ...newState};
        this.refreshUI && this.refreshUI();
    }

    /**
     * Internal method invoked when component is being mounted. This one is used internally and is not intended
     * to be "overriden" by inheriting classes.
     * 
     * DO NOT OVERRIDE THIS METHOD!
     */
    _componentDidMount() {
        this._mounted = true;
        this.componentDidMount();
    }

    /**
     * Internal method invoked when component is about to be unmounted. This one is used internally and is not intended
     * to be "overriden" by inheriting classes.
     * 
     * DO NOT OVERRIDE THIS METHOD!
     */
    _componentWillUnmount() {
        this._mounted = false;
        this.componentWillUnmount();
    }

    /**
     * Invoked by the Dialog component when a dialog is mounted. Allows custom classes to execute on-mount logic.
     */
    componentDidMount() {
        // nothing to do
    }

    /**
     * Invoked by the Dialog component when a dialog is unmounted. Allows custom classes to execute on-unmount logic.
     */
    componentWillUnmount() {
        // nothing to do
    }

    /**
     * Indicates whether the state of this dialog allows the dialog to be confirmed by pressing the Enter key.
     */
    canAcceptWithEnterKeyPress() {
        return true;
    }

    /**
     * Indicates whether the state of this dialog allows the dialog to be dismissed by pressing the Escape key.
     */
    canDismissWithEscapeKeyPress() {
        return true;
    }

    /**
     * Indicates whether this dialog can be dismissed by clicking outside of it.
     */
    canDismissByClickingOutside() {
        return true;
    }

    handleTabKey() {
        return false;
    }

    /**
     * Dismisses the dialog by invoking the close method of the interface and passing the dismissal value for this
     * dialog type.
     */
    dismiss() {
        this._interface.close(null);
    }

    /**
     * Confirms the dialog by invoking the close method of the interface and passing the confirmation value for this
     * dialog type.
     */
    accept() {
        this._interface.close(true);
    }

    /**
     * Returns the body of the dialog.
     */
    getBody() {
        throw new PopupRuntimeError("You must not instantiate DialogBase directly, and you must replace the getBody method.");
    }

    /**
     * Returns the buttons of the dialog.
     */
    getButtons() {
        return <DialogButtons
            buttons={[
                { id: "button-dialog-ok", caption: localize(GlobalCaption.FromBackEnd.Global_OK), click: this.dismiss.bind(this) },
            ]}
        />
    }

    /**
     * Returns a custom dialog style provider.
     *
     * @returns DialogStyleProvider
     * @memberof DialogBase
     */
    getCustomStyleProvider() {
        return null; // By default, no custom styles are needed
    }
}
