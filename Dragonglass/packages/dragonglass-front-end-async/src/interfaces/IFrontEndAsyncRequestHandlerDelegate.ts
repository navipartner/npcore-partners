import { IFrontEndAsyncRequest } from "./IFrontEndAsyncRequest";

export interface IFrontEndAsyncRequestHandlerDelegate {
    (request: IFrontEndAsyncRequest): any;
}
