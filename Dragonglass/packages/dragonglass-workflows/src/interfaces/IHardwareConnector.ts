// TODO: move this to HarwareConnector project!!

export interface IHardwareConnector {
    unregisterResponseHandler(handler: string): void;
    sendRequestAsync(handler: string, content: any, context: string): Promise<void>;
    sendRequestAndWaitForResponseAsync(handler: string, content: any): Promise<any>;
    registerResponseHandler(callback: (HandlerContent: any) => void): string;
    unregisterResponseHandler(context: string): void;
}
