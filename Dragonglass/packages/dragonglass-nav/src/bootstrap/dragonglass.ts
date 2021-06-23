import { NAVEventFactory } from "./../nav/NAVEventFactory";
import { Ready } from "dragonglass-core";
import { INAVMethodDescriptor } from "../nav/INAVMethodDescriptor";

export const bootstrapSetDragonglass = () => {
    Ready.instance.run(() => {
        const keepAlive = NAVEventFactory.method({ name: "SetDragonglass", skipIfBusy: false } as INAVMethodDescriptor);
        keepAlive.raise();
    });
}
