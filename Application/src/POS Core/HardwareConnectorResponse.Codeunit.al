codeunit 6014575 "NPR HWC Response Method"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnPreSearch(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Json: Codeunit "NPR POS JSON Management";
        Response: JsonToken;
        RequestId: Guid;
        RequestIdText: Text;
    begin
        if Method <> 'HardwareConnectorResponse' then
            exit;

        Handled := true;

        Json.InitializeJObjectParser(Context, FrontEnd);
        RequestIdText := Json.GetString('requestId');
        if Evaluate(RequestId, RequestIdText) then;
        if Context.Get('response', Response) then;

        OnHardwareConnectorResponse(RequestId, Response, POSSession, FrontEnd);
    end;

    /// <summary>
    /// Event publisher that is invoked when Hardware Connector returns an awaited response to AL. This event
    /// will always be invoked for those `codeunit 6014573 "NPR Front-End: HWC"` instances on which the
    /// `AwaitResponse()` method was invoked.
    /// </summary>
    /// <param name="RequestId">Request ID assigned to the request when invoking the `AwaitResponse()` on the request object.</param>
    /// <param name="Response">Response from the Hardware Connector. It can be any value (the exact value type depends on the handler that was invoked).</param>
    /// <param name="POSSession">POS Session instance on which this request was invoked</param>
    /// <param name="FrontEnd">FrontEnd instance used to handle any front-end communication</param>
    [BusinessEvent(false)]
    local procedure OnHardwareConnectorResponse(RequestId: Guid; Response: JsonToken; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;
}
