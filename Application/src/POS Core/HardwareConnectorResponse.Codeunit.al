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

        OnHardwareConnectorResponse(RequestId, Response);
    end;

    [BusinessEvent(false)]
    local procedure OnHardwareConnectorResponse(RequestId: Guid; Response: JsonToken)
    begin
    end;
}
