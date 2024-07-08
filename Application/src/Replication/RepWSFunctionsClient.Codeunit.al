codeunit 6014692 "NPR Rep. WS Functions Client" implements "NPR Rep. WS IFunctions"
{
    Access = Internal;
    procedure GetLastReplicationCounter(TableId: Integer; ServiceSetup: Record "NPR Replication Service Setup"; Endpoint: Record "NPR Replication Endpoint"): BigInteger
    var
        [NonDebuggable]
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
        ErrorTxt: Text;
        JsonText: Text;
        StatusCode: Integer;
        Json: JsonObject;
        JToken: JsonToken;
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(BuildODataV4URI('ReplicationFunctions_GetLastReplicationCounter', ServiceSetup));
        RequestMessage.GetHeaders(Headers);
        ServiceSetup.SetRequestHeadersAuthorization(Headers);
        Headers.Add('Company', ServiceSetup.GetCompanyId());

        Json.Add('tableId', TableId);
        Json.WriteTo(JsonText);
        RequestMessage.Content.WriteFrom(JsonText);
        RequestMessage.Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        if not ReplicationAPI.IsSuccessfulRequest(Client.Send(RequestMessage, ResponseMessage), ResponseMessage, ErrorTxt, StatusCode) then
            Error(ErrorTxt);

        ResponseMessage.Content.ReadAs(JsonText);
        Json.ReadFrom(JsonText);
        if not Json.Get('value', JToken) then
            Error('Unexpected Response.');

        Exit(JToken.AsValue().AsBigInteger());
    end;

    local procedure BuildODataV4URI(FunctionName: Text; ServiceSetup: Record "NPR Replication Service Setup") URI: Text
    begin
        URI := GetUrl(ClientType::ODataV4).TrimEnd('/');
        IF URI.ToLower().Contains('?tenant=') then
            URI := URI.Remove(URI.ToLower().IndexOf('?tenant='), StrLen(URI) - URI.ToLower().IndexOf('?tenant=') + 1).TrimEnd('/'); // remove tenant
        URI += '/' + FunctionName;
        if ServiceSetup."From Company Tenant" <> '' then
            URI += '/?tenant=' + ServiceSetup."From Company Tenant";
    end;

}