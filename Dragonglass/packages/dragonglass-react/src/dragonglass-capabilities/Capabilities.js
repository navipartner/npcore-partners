
import { SelfServiceCapability } from "./SelfServiceCapability";

let selfService = null;

export class Capabilities {
    static initialize() {
        selfService = new SelfServiceCapability();
    }

    static get SelfService() {
        return selfService || (selfService = new SelfServiceCapability());
    }
}
