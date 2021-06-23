import { GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { NAVEventFactory } from "dragonglass-nav";
import { AppInterface } from "../dragonglass-capabilities/AppInterface";

let initialized = false;

export const initializeFrontEndId = () => {
    if (initialized)
        return;

    initialized = true;

    const frontEndId = NAVEventFactory.method({ name: "FrontEndId" });

    const hardwareId = {
        hardware: "",
        session: "",
        host: ""
    };

    const defaultFrontEndId = "WebBrowser;;";

    const retrieveFrontEndId = async () => {
        const response = (await AppInterface.getFrontEndId() || defaultFrontEndId).split(";");

        hardwareId.hardware = response[0];
        if (response.length >= 1)
            hardwareId.session = response[1];
        if (response.length >= 2)
            hardwareId.host = response[2];

        frontEndId.raise(hardwareId);
    };

    GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.FRAMEWORK_READY, retrieveFrontEndId);
};
