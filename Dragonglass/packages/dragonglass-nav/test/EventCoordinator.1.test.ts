import { Debug, DEBUG_SEVERITY, InvalidOperationError, Ready } from "dragonglass-core";
import { StateStore } from "dragonglass-redux";
import { EventCoordinator } from "../src/nav/EventCoordinator";
import { NAVEventFactory } from "../src/nav/NAVEventFactory";
import { NAV, NAVManager } from "../src/nav/NAVManager";
import { mockDocument } from "./mock/mock.document";
import { mockNAVFramework } from "./mock/mock.NAVFramework";
import { mockStateStore } from "./mock/mock.StateStore";
import { mockWindow } from "./mock/mock.window";

describe("EventCoordinator class", () => {

    test("Instantiation and initialization", () => {
        Ready.initialize(mockWindow, mockDocument);
        
        expect(() => {let c = new EventCoordinator({} as NAVManager, {} as StateStore, {} as Debug)}).toThrowError(InvalidOperationError);
        expect(() => EventCoordinator.instance).toThrowError(InvalidOperationError);
        NAVManager.initialize(mockStateStore(), mockNAVFramework(), "", DEBUG_SEVERITY.WARNING);
        expect(EventCoordinator.instance).toBeInstanceOf(EventCoordinator);
        expect(() => EventCoordinator.initialize(NAVManager.instance, mockStateStore(), {} as Debug)).toThrowError(InvalidOperationError);
    });
});
