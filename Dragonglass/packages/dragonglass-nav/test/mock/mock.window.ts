import { EventDispatcher, IListenerDelegate } from "dragonglass-core"

const eventDispatcher = new EventDispatcher(["load"]);

export const mockWindow = {
    addEventListener: (event: string, listener: IListenerDelegate) =>  eventDispatcher.addEventListener(event, listener),

    load: () => eventDispatcher.raise("load")
};
