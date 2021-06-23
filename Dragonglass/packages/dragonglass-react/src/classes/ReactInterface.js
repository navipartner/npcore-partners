import { Popup } from "../dragonglass-popup/PopupHost";
import { InputType } from "../dragonglass-popup/enums/InputType";
import { runWorkflow } from "dragonglass-workflows";
import { getTranscendenceInstance } from "dragonglass-transcendence";
import { GlobalErrorDispatcher } from "dragonglass-core";
import { NAV } from "dragonglass-nav";
import { AppInterface } from "../dragonglass-capabilities/AppInterface";

/**
 * Represents the interface into Dragonglass that is temporarily used as fallback from Transcendence until all of Transcendence is migrated into Dragonglass.
 *
 * @export
 * @class ReactInterface
 */
export class ReactInterface {
    constructor(store) {
        this.store = store;
        this.popup = Popup;
        this.enums = {
            inputType: [InputType.DECIMAL, InputType.INTEGER, InputType.DATE, InputType.TEXT]
        };
        this.nav = NAV.instance;
        this.localization = () => this.store.getState().localization || {};
        this.executeKnownWorkflow = (name, actionInfo, parent) => runWorkflow(name, actionInfo, parent);
        this.getDataStates = () => store.getDataStates().data;
        this.raiseCriticalError = error => GlobalErrorDispatcher.raiseCriticalError(error);
        this.external = AppInterface;
    }

    dispatch(action) {
        this.store.dispatch(action);
    }

    static get transcendence() {
        return this._transcendence;
    }

    static async initializeTranscendence(store) {
        return this._transcendence = await getTranscendenceInstance(new ReactInterface(store), window);
    }
}
