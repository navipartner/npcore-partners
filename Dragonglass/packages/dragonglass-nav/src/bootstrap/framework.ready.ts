import { NAVEvent } from "../nav/NAVEvent";
import { Debug, GlobalEventDispatcher } from "dragonglass-core";
import { NAVEventFactory } from "../nav/NAVEventFactory";

let frameworkReadyEvent: NAVEvent | null;
const getFrameworkReadyEvent = () => frameworkReadyEvent || (frameworkReadyEvent = NAVEventFactory.event("OnFrameworkReady"));

const debug = new Debug("Framework");

export const bootstrapFrameworkReady = async () => {
    await getFrameworkReadyEvent().raise();
    debug.log("Completed JavaScript framework initialization.");
    GlobalEventDispatcher.frameworkReady();
};
