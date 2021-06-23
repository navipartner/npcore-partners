import { Popup } from "./PopupHost";
import { InputType } from "./enums/InputType";
import { localize } from "../components/LocalizationManager";
import { WorkflowRuntimeError } from "dragonglass-workflows";
import { simplePayment } from "./popup-proxies/simplePayment";
import { mobilePay } from "./popup-proxies/mobilePay";

export class WorkflowPopupCoordinator {
    constructor(coordinator) {
        let inDialog = false;

        Object.defineProperty(this, "inDialog", {
            get: () => inDialog
        });

        const DIALOG_STYLE = {
            CONFIRM: {
                title: localize("DialogCaption_Confirmation"),
                func: Popup.confirm
            },
            MESSAGE: {
                title: localize("DialogCaption_Message"),
                func: Popup.message
            },
            ERROR: {
                title: localize("DialogCaption_Error"),
                func: Popup.error
            }
        };

        /**
         * Shows a dialog of specified predefined style (confirmation, message, error).
         *
         * @param {Object} style Style
         * @param {Object} content Content to be shown in the dialog
         * @param {String} title Caption
         * @returns Promise
         */
        function simpleDialog(style, content, title) {
            const par = typeof content === "object"
                ? content
                : { caption: content }
            par.title = par.title || title || style.title;
            return style.func.call(Popup, par);
        }

        /**
         * Shows a numpad dialog with specified type, title, caption, and value, with input box in indicated masked state, and specified notblank behavior.
         * Returns a promise that is resolved when the dialog is closed (both Ok and Cancel resolve the promise).
         * @param {object} type Type of the dialog (decimal, integer, text, etc.)
         * @param {Object} content Content to be shown in the dialog
         * @param {string} title Title to be shown in the title bar of the dialog
         * @param {Boolean} masked Indicates whether the input should be masked (password)
         */
        function numpad(type, content, title, masked) {
            const par = typeof content === "object"
                ? content
                : { caption: content };
            par.type = type || InputType.DECIMAL;
            par.title = par.title || title || localize("DialogCaption_Numpad");
            if (masked) par.masked = true;
            return Popup.numpad(par);
        }

        /**
         * Shows an input dialog with specified configuration, title, and masked state.
         * Returns a promise that is resolved when the dialog is closed (both Ok and Cancel resolve the promise).
         * @param {Object} content Content of the dialog (contains properties to define dialog behavior)
         * @param {string} title Title to be shown in the title bar of the dialog
         * @param {boolean} masked Indicates whether the input text should be masked (password)
         */
        function input(content, title, masked) {
            const par = typeof content === "object"
                ? content
                : { caption: content };
            par.title = par.title || title || localize("DialogCaption_Numpad");
            if (masked) par.masked = true;
            return Popup.input(par);
        }

        async function showPopup(popup) {
            const tracker = coordinator.open();
            const result = await popup;
            tracker.resolve();
            return result;
        }

        function getCustomDialogReference(content, title) {
            if (content.__dialog_interface__)
                throw new WorkflowRuntimeError("The content object passed to popup.open must not have __dialog_interface__ property.");

            const __dialog_interface__ = {};
            const dialogPromise = showPopup(Popup.customDialog({...content, __dialog_interface__ }, title))

            return {
                completeAsync: () => dialogPromise,
                update: __dialog_interface__.update,
                close: __dialog_interface__.close,
                effects: __dialog_interface__.effects
            };
        }

        /**
         * The returned object is assigned to the popup variable in the outside scope and contains wrapper invokers for the functions above.
         * The exception is the calendar function that is fully defined below.
         */
        this.numpad = async (content, title) => await showPopup(numpad(InputType.DECIMAL, content, title));
        this.intpad = async (content, title) => await showPopup(numpad(InputType.INTEGER, content, title));
        this.datepad = async (content, title) => await showPopup(numpad(InputType.DATE, content, title));
        this.stringpad = async (content, title) => await showPopup(numpad(InputType.TEXT, content, title));
        this.passwordpad = async (content, title) => await showPopup(numpad(InputType.TEXT, content, title, true));
        this.input = async (content, title) => await showPopup(input(content, title));
        this.password = async (content, title) => await showPopup(input(content, title, true));
        this.menu = async (content, title) => await showPopup(Popup.menu(content, title));
        this.optionsMenu = async (content, title) => await showPopup(Popup.optionsMenu(content, title));
        this.message = async (content, title) => await showPopup(simpleDialog(DIALOG_STYLE.MESSAGE, content, title));
        this.confirm = async (content, title) => await showPopup(simpleDialog(DIALOG_STYLE.CONFIRM, content, title));
        this.error = async (content, title) => await showPopup(simpleDialog(DIALOG_STYLE.ERROR, content, title));
        this.calendarPlusLines = async (content, title) => await showPopup(Popup.calendarPlusGrid(content, title));
        this.configuration = async (content, title) => await showPopup(Popup.configuration(content, title));
        this.configurationTable = async (content, title) => await showPopup(Popup.configurationTable(content, title));
        this.timeout = async (content, title) => await showPopup(Popup.timeout(content, title));
        this.open = (content, title) => getCustomDialogReference(content, title);
        this.simplePayment = content => simplePayment(this, content);
        this.mobilePay = content => mobilePay(this, content);
        this.lookup = async (content, title) => await showPopup(Popup.lookup(content, title));

        this.hospitality = {
            seatingSetup: async (content, title) => await showPopup(Popup.seatingSetup(content, title)),
            splitBill: async (content, title) => await showPopup(Popup.splitBill(content, title))
        };
    }
};
