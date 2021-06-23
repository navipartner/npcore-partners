import { INAVEventDescriptor } from "./INAVEventDescriptor";

export interface INAVMethodDescriptor extends INAVEventDescriptor {
    noSupport?: Function;
    processArguments?: Function;
    callback?: Function;
    awaitResponse?: boolean;
    forceAsync?: boolean;
}
