import { DEBUG_SEVERITY, Ready } from "dragonglass-core";
import { NAVEventFactory } from "../src/nav/NAVEventFactory";
import { NAVManager } from "../src/nav/NAVManager";
import { mockDocument } from "./mock/mock.document";
import { mockNAVFramework } from "./mock/mock.NAVFramework";
import { mockStateStore } from "./mock/mock.StateStore";
import { mockWindow } from "./mock/mock.window";

describe("NAVManager (part 2)", () => {

    const warn = jest.spyOn(console, "warn");
    const nav = mockNAVFramework();
    Ready.initialize(mockWindow, mockDocument);
    NAVManager.initialize(mockStateStore(), nav, "_test_1_/_test_2_", DEBUG_SEVERITY.WARNING);

    test("Interaction with NAV busy state", () => {
        let busy = nav.GetEnvironment().Busy;
        const onBusy = jest.fn().mockImplementation(b => busy = b);
        NAVManager.instance.subscribeBusyChanged(onBusy);

        expect(warn).not.toBeCalled();
        NAVManager.instance.subscribeBusyChanged(onBusy); // Attempting second subscribe! (gives warning)
        expect(warn).toBeCalledTimes(1);

        expect(busy).toBe(false);
        mockWindow.load();
        expect(busy).toBe(false);

        nav._env._setBusy(true);
        nav._env._setBusy(true);
        expect(busy).toBe(true);
        expect(NAVManager.instance.busy).toBe(true);
        nav._env._setBusy(false);
        nav._env._setBusy(false);
        expect(busy).toBe(false);
        expect(NAVManager.instance.busy).toBe(false);

        expect(onBusy).toBeCalledTimes(2);

        nav._env._setBusy(true);
        NAVManager.instance.unsubscribeBusyChanged(onBusy);
        expect(busy).toBe(true);
        expect(NAVManager.instance.busy).toBe(true);
        nav._env._setBusy(false);
        expect(busy).toBe(true); // We unsubscribed!
        expect(NAVManager.instance.busy).toBe(false);

        NAVManager.instance.unsubscribeBusyChanged(onBusy); // Attempting second unsubscribe! (gives warning)
        expect(warn).toBeCalledTimes(2);
    });

    test("MapPath tests", () => {
        expect(NAVManager.instance.mapPath("test")).toBe("_test_1_/_test_2_/test");
        expect(NAVManager.instance.mapPath("test.png")).toBe("_test_1_/_test_2_/test.png");
        NAVManager.instance.setPath("/attempt/");
        expect(NAVManager.instance.mapPath("test")).toBe("attempt/test");
        expect(NAVManager.instance.mapPath("test.png")).toBe("attempt/test.png");
    });

    test("Invoke back end", async () => {
        nav._autoBusy = false; // We don't want to test synchronicity of NAV framework at this point, want to controll it manually

        nav._env._setBusy(false);
        let firstCallback = false;
        NAVManager.instance.invokeBackEnd("", [], true, () => firstCallback = true);
        expect(firstCallback).toBe(true);

        let secondCallback = false;
        nav._env._setBusy(true);
        NAVManager.instance.invokeBackEnd("", [], true, () => secondCallback = true);
        expect(secondCallback).toBe(false);

        let thirdCallback = false;
        await new Promise(fulfill => {
            NAVManager.instance.invokeBackEnd("", [], false, () => {
                thirdCallback = true;
                fulfill();
            });
            expect(thirdCallback).toBe(false);
            nav._env._setBusy(false);
            expect(thirdCallback).toBe(true);
        });
        expect(thirdCallback).toBe(true);
    });
    
});
