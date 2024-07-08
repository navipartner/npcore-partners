codeunit 6150978 "NPR NpGp Try Get Glob Pos Serv"
{
    Access = Internal;
    TableNo = "NPR NpGp POS Sales Setup";

    trigger OnRun()
    begin
        GetGlobalPosSalesService(Rec);
    end;

    local procedure GetGlobalPosSalesService(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    var
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
    begin
        NpGpPOSSalesSetup.TestField("Service Url");

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Method := 'GET';
        RequestMessage.SetRequestUri(NpGpPOSSalesSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(ResponseMessage.ReasonPhrase);
    end;
}
