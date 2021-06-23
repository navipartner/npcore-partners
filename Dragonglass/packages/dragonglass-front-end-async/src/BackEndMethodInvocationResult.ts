import { IFrontEndAsyncRequest } from ".";
import { FrontEndAsyncRequestHandler } from "./FrontEndAsyncRequestHandler";
import { BackEndMethodInvocationAwaiter } from "dragonglass-nav";

export class BackEndMethodInvocationResult extends FrontEndAsyncRequestHandler {
  public handle(request: IFrontEndAsyncRequest) {
    const { id, method, response } = request.Content;
    BackEndMethodInvocationAwaiter.resolveResponse(id, method, response);
  }
}
