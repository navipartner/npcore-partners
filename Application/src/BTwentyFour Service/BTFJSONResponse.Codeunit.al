codeunit 6014647 "NPR BTF JSON Response" implements "NPR BTF IFormatResponse"
{
    Access = Internal;
    var
        NoBodyReturnedLbl: Label 'No body returned';

    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob")
    var
        JObject: JsonObject;
        Json: Text;
        OutStr: OutStream;
    begin
        JObject.Add('error', ErrorCode);
        JObject.Add('error_description', ErrorDescription);
        JObject.WriteTo(Json);
        Result.CreateOutStream(OutStr);
        OutStr.WriteText(Json);
    end;

    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"; StatusCode: Integer): Boolean;
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        if StatusCode = 200 then
            exit;
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit(true);
        if (JObject.Contains('error') or JObject.Contains('Error')) then
            exit(true);
        if JObject.Contains('exceptionMessage') then
            exit(true);
        if JObject.Get('message', JTOken) then
            exit(JToken.IsObject());
        if JObject.Get('Message', JTOken) then
            exit(JToken.IsObject());
    end;

    procedure GetErrorDescription(Response: Codeunit "Temp Blob"): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit(NoBodyReturnedLbl);
        if JObject.Get('exceptionMessage', JToken) then
            exit(JToken.AsValue().AsText());
        if JObject.Get('error_description', JToken) then
            exit(JToken.AsValue().AsText());
        if JObject.Get('message', JToken) then
            exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    procedure GetToken(Response: Codeunit "Temp Blob"): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        if not JObject.Get('access_token', JToken) then
            exit;
        exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    procedure FoundToken(Response: Codeunit "Temp Blob"): Boolean
    var
        JObject: JsonObject;
        InStr: InStream;
        Json: Text;
    begin
        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit;
        exit(JObject.Contains('access_token'));
    end;

    procedure GetFileExtension(): Text
    begin
        exit('json');
    end;

    procedure GetOrder(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessOrder(Content, SalesHeader, SalesLine, Handled);
        exit(Handled);
    end;

    procedure GetInvoice(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessInvoice(Content, SalesHeader, SalesLine, Handled);
        exit(Handled);
    end;

    procedure GetOrderResp(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessOrderResp(Content, SalesHeader, SalesLine, Handled);
        exit(Handled);
    end;

    procedure GetPriceCat(Content: Codeunit "Temp Blob"; var ItemWrks: Record "NPR Item Worksheet"; var ItemWrksLine: Record "NPR Item Worksheet Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessPriceCatalogue(Content, ItemWrks, ItemWrksLine, Handled);
        exit(Handled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessOrder(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessInvoice(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessOrderResp(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessPriceCatalogue(Content: Codeunit "Temp Blob"; var ItemWrks: Record "NPR Item Worksheet"; var ItemWrksLine: Record "NPR Item Worksheet Line"; var Handled: Boolean)
    begin
    end;
}
