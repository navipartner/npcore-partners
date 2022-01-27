/// <summary>
/// Represents a Hardware Connector request. Sending this request to `FrontEnd.InvokeFrontEndAsync` method routes this
/// request to the Hardware Connector application. Invoking this method doesn't depend on workflows and may be invoked
/// from within a call stack of both v1 and v2 workflows, as well as outside of any workflow as long as the POS page
/// is loaded.
/// 
/// A typical HardwareConnector request for JavaScript looks like this:
/// 
/// ```typescript
/// hwc.sendRequestAndWaitForResponse(handler: string, request: Object);
/// ```
/// 
/// The `handler` and `string` properties are mapped to this request. To invoke Hardware Connector from AL, do this:
/// 
/// ```
/// var
///     Request: Codeunit "NPR Front-End HWC";
/// begin
///     Request.SetHandler(Text);
///     Request.SetRequest(JsonObject);
///     FrontEnd.InvokeFrontEndAsync(Request);
/// end;
/// ```
/// 
/// If you need to receive a response from Hardware Connector in AL, then you must call `AwaitResponse` method like this:
/// 
/// ```
/// RequestID := Request.AwaitResponse();
/// ```
/// 
/// Then, you must listen to `OnHardwareConnectorResponse` event method of the `codeunit 6014575 "NPR HWC Response Method"`.
/// The subscriber must compare the received `RequestId` argument to the expected one obtained by `AwaitResponse`.
/// 
/// The direct invocation of Hardware Connector from AL does not (currently) support the `hwc.sendRequestAsync()` method.
/// </summary>
codeunit 6014573 "NPR Front-End: HWC" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _request: JsonObject;
        _awaitResponse: Boolean;
        _requestId: Guid;
        _handler: Text;

    #region "NPR Front-End Async Request" implementation

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'InvokeHardwareConnector');
        Json.Add('Content', _content);
        Json.Add('handler', _handler);
        Json.Add('request', _request);
        if (_awaitResponse) then begin
            Json.Add('requestId', _requestId);
            Json.Add('awaitResponse', _awaitResponse);
        end;
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;

    procedure SetContent(Json: Interface "NPR IJsonSerializable")
    begin
        _content := Json.GetJson();
    end;

    #endregion

    /// <summary>
    /// Defines the `request` parameter for the `sendRequestAndWaitForResponseAsync` invocation:
    /// ```
    /// hwc.sendRequestAndWaitForResponse(handler: string, request: Object);
    /// ```
    /// </summary>/// 
    /// <param name="Request"></param>
    procedure SetRequest(Request: JsonObject)
    begin
        _request := Request;
    end;

    /// <summary>
    /// Instructs the front-end that the Hardware Connector handler that will execute the request is going
    /// to return a value. If you invoke this method on a request, then front end will await for the response
    /// of the `sendRequestAndWaitForResponseAsync` method, and will pass the response to AL.
    /// 
    /// This method returns a Guid that uniquely identifies the request/response pair. When front-end responds,
    /// the `OnHardwareConnectorResponse` of the `codeunit 6014575 "NPR HWC Response Method"` event is invoked,
    /// and it will contain the Guid identifying the request, and whatever response was sent by Hardware
    /// Connector.
    /// </summary>
    /// <returns>Request ID of this request. Use this to match individual responses to specific requests.</returns>
    procedure AwaitResponse(): Guid
    begin
        _awaitResponse := true;
        _requestId := CreateGuid();
        exit(_requestId);
    end;

    /// <summary>
    /// Defines the `handler` parameter for the `sendRequestAndWaitForResponseAsync` invocation:
    /// ```
    /// hwc.sendRequestAndWaitForResponse(handler: string, request: Object);
    /// ```
    /// </summary>
    /// <param name="Handler">Hardware Connector specific handler that will execute this request</param>
    procedure SetHandler(Handler: Text)
    begin
        _handler := Handler;
    end;
}
