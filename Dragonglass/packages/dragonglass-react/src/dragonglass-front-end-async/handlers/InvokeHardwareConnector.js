import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { NAVEventFactory } from "dragonglass-nav";
import hwc from "./../../HardwareConnector";

let responseMethod;

export class InvokeHardwareConnector extends FrontEndAsyncRequestHandler {
  getResponseMethod() {
    if (!responseMethod) {
      responseMethod = NAVEventFactory.method({ name: "HardwareConnectorResponse" });
    }
    return responseMethod;
  }

  async handle(req) {
    const { handler, request, requestId, awaitResponse } = req;
    const response = await hwc.sendRequestAndWaitForResponseAsync(handler, request);

    if (awaitResponse) {
      this.getResponseMethod().raise({ requestId, response });
    }
  }
}
