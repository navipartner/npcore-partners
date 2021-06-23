import { Debug, InvalidOperationError } from "dragonglass-core";
import { StateStore } from "dragonglass-redux";
import { EventCoordinator } from "../src/nav/EventCoordinator";
import { NAVEventFactory } from "../src/nav/NAVEventFactory";

describe("NAVEventFactory class", () => {

    const initialize = () => NAVEventFactory.initialize({} as EventCoordinator, {} as StateStore, new Debug("test"));

    test("Initialization and internal consistency", ()=> {
        expect(() => NAVEventFactory.event("test")).toThrowError(InvalidOperationError);
        expect(() => NAVEventFactory.method("test")).toThrowError(InvalidOperationError);
        initialize();
        expect(() => initialize()).toThrowError(InvalidOperationError);
    });
});
