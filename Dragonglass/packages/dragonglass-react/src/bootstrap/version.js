import { GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { AppInterface } from "../dragonglass-capabilities/AppInterface";

const DRAGONGLASS_VERSION = "6.1.2343.27";

export const initializeVersion = () => {
  GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.FRAMEWORK_READY, () =>
    AppInterface.invokeFrontEndEvent("announceFrameworkVersion", {
      version: DRAGONGLASS_VERSION,
    })
  );
};
