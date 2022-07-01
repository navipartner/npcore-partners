import App from "./App.svelte";
import HardwareConnector from "np-hwc";
import { caption } from "./stores.js";

(window as any).SendRequest = async function (handler: string, request: any, captionNew: string): Promise<void> {
    caption.set(captionNew);

    try {
        const response = await (window as any)._np_hardware_connector.sendRequestAndWaitForResponseAsync(
            handler,
            request
        );
        (window as any).Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ResponseReceived', [response]);
    } catch (exception: any) {
        console.error(exception);
        (window as any).Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ExceptionCaught', [exception.message]);
    }
};

function initializeAddin(): void {
    //Render Svelte GUI into element provided by BC iframe
    /* eslint-disable-next-line */
    const app = new App({ target: document.getElementById('controlAddIn')! });

    //Hardware Connector library
    (window as any)._np_hardware_connector
        ? (window as any)._np_hardware_connector.getSocketState() > 1 &&
          ((window as any)._np_hardware_connector = new HardwareConnector())
        : ((window as any)._np_hardware_connector = new HardwareConnector());

    //Function invoked by BC backend
    (window as any).Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady');
}

if (document.readyState === 'complete') {
    initializeAddin();
} else {
    window.addEventListener('load', initializeAddin);
}