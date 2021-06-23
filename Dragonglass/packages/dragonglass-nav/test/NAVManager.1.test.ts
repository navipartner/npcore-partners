import { DEBUG_SEVERITY, InvalidOperationError, Ready } from "dragonglass-core";
import { INAVFramework } from "../src/nav/INAVFramework";
import { NAVManager } from "../src/nav/NAVManager";
import { mockDocument } from "./mock/mock.document";
import { mockStateStore } from "./mock/mock.StateStore";
import { mockWindow } from "./mock/mock.window";

describe("NAVManager (part 1)", () => {
    
    test("Instantiation and initialization", () => {
        expect(() => { const nav = NAVManager.instance }).toThrowError(InvalidOperationError);
        expect(() => { const nav = new NAVManager({} as INAVFramework, "", DEBUG_SEVERITY.CRITICAL) }).toThrowError(InvalidOperationError);

        Ready.initialize(mockWindow, mockDocument);
        NAVManager.initialize(mockStateStore(), {} as INAVFramework, "", DEBUG_SEVERITY.CRITICAL);
        expect(() => NAVManager.initialize(mockStateStore(), {} as INAVFramework, "", DEBUG_SEVERITY.CRITICAL)).toThrowError(InvalidOperationError);
    });

});