import { NAVEventFactory } from "./../nav/NAVEventFactory";
import { Ready } from "dragonglass-core";
import { INAVMethodDescriptor } from "../nav/INAVMethodDescriptor";

export const bootstrapKeepAlive = () => {
    Ready.instance.run(() => {
        const keepAlive = NAVEventFactory.method({ name: "KeepAlive", skipIfBusy: true } as INAVMethodDescriptor);
        setInterval(() => keepAlive.raise(), 239000);
    });
}
